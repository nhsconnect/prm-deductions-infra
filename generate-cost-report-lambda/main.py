import datetime
import logging
import os
import re
import time
import traceback
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from enum import Enum

import boto3
import botocore
import yaml
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

path_matcher = re.compile(r'(.*)\$\{([^}^{]+)\}')


def yaml_constructor_for_environment_variables(loader, node):
    """ Extract the matched value, expand env variable, and replace the match """
    value = node.value
    match = path_matcher.match(value)
    return match.group(1) + os.environ.get(match.group(2)) + value[match.end():]


def get_ssm_parameter(parameter_name):
    client = boto3.client('ssm', region_name=region)
    return client.get_parameter(
        Name=parameter_name
    )


yaml.SafeLoader.add_implicit_resolver('!path', path_matcher, None)
yaml.SafeLoader.add_constructor('!path', yaml_constructor_for_environment_variables)

with open("cost-report-configuration.yml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile, Loader=yaml.SafeLoader)

# Import environment variable defined in Lambda, if it's not existed, use values defined in cost-report-configuration.yml
environment = cfg['environment']
account_id = cfg['account_id']
report_output_location = cfg['cur_output_location']
glue_db = cfg['cur_db']
glue_table = cfg['cur_table']
cur_report_name = cfg['cur_report_name']
subject = cfg['subject']
body_text = cfg['body_text']
region = os.environ.get('REGION')
if not region:
    region = cfg['region']
sender_email_ssm_parameter = cfg['sender_email_ssm_parameter']
recipient_email_ssm_parameter = cfg['recipient_email_ssm_parameter']
support_email_ssm_parameter = cfg['support_email_ssm_parameter']
sender_email = get_ssm_parameter(sender_email_ssm_parameter)['Parameter']['Value']
recipient_emails = get_ssm_parameter(recipient_email_ssm_parameter)['Parameter']['Value']
support_email_address = get_ssm_parameter(support_email_ssm_parameter)['Parameter']['Value']
athena_queries = cfg['query_string_list']
queries_to_execute = []
tempPath = '/tmp'
# Target bucket and key for CUR query results in s3
cur_bucket = report_output_location.split('//')[1].split('/')[0]
cur_key_path = report_output_location.split('//')[1].lstrip(cur_bucket).lstrip('/')
query_execution_month_parameter = datetime.datetime.now().month
query_execution_year_parameter = datetime.datetime.now().year

current_date = (datetime.date.today()).strftime('%Y-%m-%d')
file_name = f'{environment}-{account_id}-aws-cost-and-usage-report-{current_date}.csv'


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
    'CUR_TABLE': glue_table,
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
    logger.info("Starting CUR query execution ... ")
    resp = None
    for query_index in range(len(queries_to_execute)):
        resp = client.start_query_execution(
            QueryString=queries_to_execute[query_index]['queryString'],
            ResultConfiguration={
                'OutputLocation': report_output_location
            })
        queries_to_execute[query_index]['queryId'] = resp['QueryExecutionId']
        logger.info(
            "Query to execute is: " + queries_to_execute[query_index]['queryString'] + " QueryId is: " +
            queries_to_execute[query_index][
                'queryId'])

    wait_for_query_execution_seconds = 5
    query_execution_duration = 60  # 5 minutes

    while query_execution_duration > 0:
        query_execution_duration = query_execution_duration - 1
        response_get_query_details = client.get_query_execution(
            QueryExecutionId=resp['QueryExecutionId']
        )
        status = response_get_query_details['QueryExecution']['Status']['State']
        if (status == AthenaQueryExecutionStatus.FAILED) or (status == AthenaQueryExecutionStatus.CANCELLED):
            failure_reason = response_get_query_details['QueryExecution']['Status']['StateChangeReason']
            logger.error("Query either FAILED or CANCELED, reason is: " + failure_reason, exc_info=True)
            raise Exception("Athena query either FAILED or CANCELED with reason " + failure_reason)

        elif status == AthenaQueryExecutionStatus.QUEUED:
            logger.info('Query queued, waiting for query execution to begin')
            time.sleep(wait_for_query_execution_seconds)

        elif status == AthenaQueryExecutionStatus.SUCCEEDED:
            logger.info("Query execution succeeded, the query ID is: " + resp['QueryExecutionId'])
            location = response_get_query_details['QueryExecution']['ResultConfiguration']['OutputLocation']

            response_query_result = client.get_query_results(
                QueryExecutionId=resp['QueryExecutionId']
            )
            if len(response_query_result['ResultSet']['Rows']) > 1:
                logger.info("Query response result is more than one row, splitting header and rows!")
                header = response_query_result['ResultSet']['Rows'][0]
                rows = response_query_result['ResultSet']['Rows'][1:]
                header = [obj['VarCharValue'] for obj in header['Data']]
                logger.info("Query result output location is: " + location)
                result = [dict(zip(header, get_var_char_values(row))) for row in rows]
            else:
                logger.info("No results found!")


def fetch_cost_report_into_lambda_directory(bucket_name, key_path, query_list):
    os.chdir(tempPath)
    s3 = boto3.resource('s3')
    for i in range(len(query_list)):
        logger.info(
            "Copying query result from output source location: s3://" + bucket_name + "/" + key_path + query_list[i][
                'queryId'] + ".csv")
        try:
            s3.Bucket(bucket_name).download_file(key_path + query_list[i]['queryId'] + '.csv', file_name)
            is_file_downloaded = os.path.isfile('/tmp/' + file_name)
            logger.info(f"Successfully copied the report:  {is_file_downloaded}")
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "404":
                logger.error("The target query result file does not exist.", exc_info=True)
                raise e
            else:
                logger.error("Unexpected error while fetching cost report into Lambda directory.", exc_info=True)
                raise e


def send_error_details_to_support(error_message):
    email_body = f"Hi, \n" \
                 f"There was an error generating the cost and usage report. Please find details below: \n\n" \
                 f"Error description: \n{error_message}\n\n" \
                 f"Error stack trace:\n" \
                 f"{traceback.format_exc()} \n\n" \
                 f"Regards, \n" \
                 f"PRM Team"
    send_email("Error generating PRM cost and usage report", sender_email, support_email_address, None, email_body)


def send_email(email_subject, email_sender, email_receivers, report_name, email_body):
    logger.info("Sending email via SES")
    os.chdir(tempPath)
    client = boto3.client('ses', region_name=region)
    message = MIMEMultipart('mixed')
    message['Subject'] = email_subject
    message['From'] = email_sender
    message['To'] = email_receivers
    if report_name:
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
        logger.error(e.response['Error']['Message'], exc_info=True)
    finally:
        client.close()


def lambda_handler(event, context):
    try:
        execute_cur_queries_on_athena()
        fetch_cost_report_into_lambda_directory(cur_bucket, cur_key_path, queries_to_execute)
    except Exception as e:
        send_error_details_to_support("Unexpected exception while generating cost and usage report. \n" + str(e))
    else:
        response = send_email(subject, sender_email, recipient_emails, file_name, body_text)
        return response
