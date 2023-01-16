import datetime
import os
import re
import time
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from enum import Enum

import boto3
import botocore
import yaml
from botocore.exceptions import ClientError

path_matcher = re.compile(r'(.*)\$\{([^}^{]+)\}')


def yaml_constructor_for_environment_variables(loader, node):
    """ Extract the matched value, expand env variable, and replace the match """
    value = node.value
    match = path_matcher.match(value)
    return match.group(1) + os.environ.get(match.group(2)) + value[match.end():]


def get_ssm_parameter(parameter_name):
    print(parameter_name)
    client = boto3.client('ssm', region_name=region)
    return client.get_parameter(
        Name=parameter_name
    )


yaml.SafeLoader.add_implicit_resolver('!path', path_matcher, None)
yaml.SafeLoader.add_constructor('!path', yaml_constructor_for_environment_variables)

with open("cost-report-configuration.yml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile, Loader=yaml.SafeLoader)

# Import environment variable defined in Lambda, if it's not existed, use values defined in cost-report-configuration.yml
ENVIRONMENT = os.environ.get('ENVIRONMENT')
report_output_location = cfg['cur_output_location']
glue_db = cfg['cur_db']
cur_report_name = cfg['cur_report_name']
subject = cfg['subject']
body_text = cfg['body_text']
region = os.environ.get('REGION')
if not region:
    region = cfg['region']
sender_email_ssm_parameter = cfg['sender_email_ssm_parameter']
recipient_email_ssm_parameter = cfg['recipient_email_ssm_parameter']
sender = get_ssm_parameter(sender_email_ssm_parameter)['Parameter']['Value']
recipient = get_ssm_parameter(recipient_email_ssm_parameter)['Parameter']['Value']
athena_queries = cfg['query_string_list']
queries_to_execute = []
tempPath = '/tmp'
# Target bucket and key for CUR query results in s3
cur_bucket = report_output_location.split('//')[1].split('/')[0]
cur_key_path = report_output_location.split('//')[1].lstrip(cur_bucket).lstrip('/')
query_execution_month_parameter = datetime.datetime.now().month
query_execution_year_parameter = datetime.datetime.now().year - 1 if query_execution_month_parameter == 12 \
    else datetime.datetime.now().year

current_date = (datetime.date.today()).strftime('%Y-%m-%d')
file_name = f'ORC-{ENVIRONMENT}-aws-cost-and-usage-report-{current_date}.csv'


class AthenaQueryExecutionStatus(str, Enum):
    QUEUED = 'QUEUED'
    RUNNING = 'RUNNING'
    SUCCEEDED = 'SUCCEEDED'
    FAILED = 'FAILED'
    CANCELLED = 'CANCELLED'


def populate_query_parameters(query, substitutions):
    substrings = sorted(substitutions, key=len, reverse=True)
    regex = re.compile('|'.join(map(re.escape, substrings)))
    return regex.sub(lambda match: substitutions[match.group(0)], query)


query_parameters = {
    'CUR_DB': glue_db,
    'CUR_YEAR': str(query_execution_year_parameter),
    'CUR_MONTH': str(query_execution_month_parameter)
}
for index in range(len(athena_queries)):
    query = populate_query_parameters(list(athena_queries[index].values())[0], query_parameters)
    queries_to_execute.append({'name': list(athena_queries[index].keys())[0], 'queryString': query})


def get_var_char_values(d):
    rowList = []
    for obj in d['Data']:
        if obj.get('VarCharValue'):
            rowList.append(obj['VarCharValue'])
        else:
            rowList.append("")
    return rowList

def execute_cur_queries_on_athena():
    client = boto3.client('athena', region_name=region)
    print("Starting query CUR ... ")
    resp = None
    for query_index in range(len(queries_to_execute)):
        print("Query is: " + queries_to_execute[query_index]['queryString'])
        resp = client.start_query_execution(
            QueryString=queries_to_execute[query_index]['queryString'],
            ResultConfiguration={
                'OutputLocation': report_output_location
            })
        queries_to_execute[query_index]['queryId'] = resp['QueryExecutionId']
        print(
            "Query " + queries_to_execute[query_index]['name'] + ' cost, queryId is ' + queries_to_execute[query_index][
                'queryId'])

    wait_for_query_execution_seconds = 5
    query_execution_duration = 60  # 5 minutes

    while query_execution_duration > 0:
        query_execution_duration = query_execution_duration - 1
        response_get_query_details = client.get_query_execution(
            QueryExecutionId=resp['QueryExecutionId']
        )
        status = response_get_query_details['QueryExecution']['Status']['State']
        print("Current Query Execution Status is: " + status)
        if (status == AthenaQueryExecutionStatus.FAILED) or (status == AthenaQueryExecutionStatus.CANCELLED):
            failure_reason = response_get_query_details['QueryExecution']['Status']['StateChangeReason']
            print("Query either FAILED or CANCELED, reason is: " + failure_reason)
            return False, False

        elif status == AthenaQueryExecutionStatus.QUEUED:
            time.sleep(1)
            print('Waiting 100ms for execution!')
            continue

        elif status == AthenaQueryExecutionStatus.SUCCEEDED:
            location = response_get_query_details['QueryExecution']['ResultConfiguration']['OutputLocation']
            print("Query execution succeeded, the query ID is: " + resp['QueryExecutionId'])

            # Function to get output results
            response_query_result = client.get_query_results(
                QueryExecutionId=resp['QueryExecutionId']
            )
            if len(response_query_result['ResultSet']['Rows']) > 1:
                print("Query response result is more than one row, splitting header and rows!")
                header = response_query_result['ResultSet']['Rows'][0]
                rows = response_query_result['ResultSet']['Rows'][1:]
                header = [obj['VarCharValue'] for obj in header['Data']]
                print(location)
                result = [dict(zip(header, get_var_char_values(row))) for row in rows]

                return location, result
            else:
                print("No results found!")
                return location, None
    else:
        time.sleep(wait_for_query_execution_seconds)

    return False


def fetch_cost_report_into_lambda_directory(bucket_name, key_path, query_list):
    os.chdir(tempPath)
    s3 = boto3.resource('s3')
    for i in range(len(query_list)):
        print("Copy query result: s3://" + bucket_name + "/" + key_path + query_list[i]['queryId'] + ".csv")
        try:
            s3.Bucket(bucket_name).download_file(key_path + query_list[i]['queryId'] + '.csv',
                                                 file_name)
            is_file_downloaded = os.path.isfile('/tmp/' + file_name)
            print(f"Successfully downloaded the report:  {is_file_downloaded}")
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "404":
                print("The target query result file does not exist.")
            else:
                raise


def send_report_via_email(ses_region, email_subject, email_sender, email_receivers, report_name, email_body):
    os.chdir(tempPath)
    print("Sending test email via SES... ")
    client = boto3.client('ses', region_name=ses_region)
    message = MIMEMultipart('mixed')
    message['Subject'] = email_subject
    message['From'] = email_sender
    message['To'] = email_receivers

    email_attachment = MIMEApplication(open(report_name, 'rb').read())
    email_attachment.add_header('Content-Disposition', 'attachment', filename=os.path.basename(report_name))
    message.attach(email_attachment)
    message.attach(MIMEText(email_body))
    try:
        response = client.send_raw_email(
            Source=email_sender,
            Destinations=email_receivers.split(','),
            RawMessage={
                'Data': message.as_string()
            }
        )
        return response
    except ClientError as e:
        print(e.response['Error']['Message'])


def lambda_handler(event, context):
    execute_cur_queries_on_athena()
    fetch_cost_report_into_lambda_directory(cur_bucket, cur_key_path, queries_to_execute)
    response = send_report_via_email(region, subject, sender, recipient, file_name, body_text)
    return response

lambda_handler(None, None)