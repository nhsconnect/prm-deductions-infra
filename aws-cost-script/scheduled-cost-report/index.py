import boto3
import botocore
import datetime
import os
import re
import time
import yaml
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import COMMASPACE, formatdate
from botocore.exceptions import ClientError

# TODO Set environment using terraform
os.environ["ENVIRONMENT"] = "dev"

path_matcher = re.compile(r'(.*)\$\{([^}^{]+)\}')


def path_constructor(loader, node):
    ''' Extract the matched value, expand env variable, and replace the match '''
    value = node.value
    match = path_matcher.match(value)
    return match.group(1) + os.environ.get(match.group(2)) + value[match.end():]


yaml.SafeLoader.add_implicit_resolver('!path', path_matcher, None)
yaml.SafeLoader.add_constructor('!path', path_constructor)

with open("config.yml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile, Loader=yaml.SafeLoader)

# TODO remove following lines.
print(os.environ.get('ENVIRONMENT'))  ## /home/abc
print(cfg['CUR_Output_Location'])
print(cfg['CUR_DB'])
print(cfg['CUR_Report_Name'])

# Import environment variable defined in Lambda, if it's not existed, use values defined in config.yml
curOutLoc = os.environ.get('CUR_OUTPUT_LOCATION')
ENVIRONMENT = os.environ.get('ENVIRONMENT')
if not curOutLoc:
    curOutLoc = cfg['CUR_Output_Location']
curDB = os.environ.get('CUR_DB')
if not curDB:
    curDB = cfg['CUR_DB']
curReportName = os.environ.get('CUR_REPORT_NAME')
if not curReportName:
    curReportName = cfg['CUR_Report_Name']
sender = os.environ.get('SENDER')
if not sender:
    sender = cfg['Sender']
recipient = os.environ.get('RECIPIENT')
if not recipient:
    recipient = cfg['Recipient']
subject = os.environ.get('SUBJECT')
if not subject:
    subject = cfg['Subject']
bodyText = os.environ.get('BODY_TEXT')
if not bodyText:
    bodyText = cfg['Body_Text']
region = os.environ.get('REGION')
if not region:
    region = cfg['Region']

# TODO: Do not convert to xlsx format, retain csv fromat.
# temp path for converting csv to xlsx file, adding graph, and combining mulitple files to single one
tempPath = '/tmp'
# Expiration time for checking Athena query status, default value is 180 seconds
queryExpiration = 180

# Target bucket and key for CUR query results in s3
curBucket = curOutLoc.split('//')[1].split('/')[0]
curKeyPath = curOutLoc.split('//')[1].lstrip(curBucket).lstrip('/')

# Get current year, month and week
curYear = datetime.datetime.now().year
curMonth = datetime.datetime.now().month
# if current month is Jan or Feb, set last year/month (and previous last month) correctly as report provides data in the past three months
if curMonth == 1:
    curOrLastYr = curYear - 1
    lastYear = curYear - 1
    lastMon = 12
    preLastMon = 11
elif curMonth == 2:
    curOrLastYr = curYear
    lastYear = curYear - 1
    lastMon = 1
    preLastMon = 12
else:
    curOrLastYr = curYear
    lastYear = curYear
    lastMon = curMonth - 1
    preLastMon = curMonth - 2

qStr = cfg['Query_String_List']
# print(qStr[0].values()[0])
qStrList = []


# Multiple charactors replacement in a string
def multReplace(string, substitutions):
    substrings = sorted(substitutions, key=len, reverse=True)
    regex = re.compile('|'.join(map(re.escape, substrings)))
    return regex.sub(lambda match: substitutions[match.group(0)], string)


qStrSub = {
    'CUR_DB': curDB,
    'CUR_YEAR': str(curYear),
    'CUR_MONTH': str(curMonth),
    # 'CUR_WEEK': str(curWk),
    'CUR_OR_LAST_YEAR': str(curOrLastYr),
    'LAST_YEAR': str(lastYear),
    'LAST_MONTH': str(lastMon),
    # 'LAST_WEEK': str(lastWk),
    'PRE_LAST_MONTH': str(preLastMon)
    # 'PRE_LAST_WEEK': str(preLastWk)
}
for i in range(len(qStr)):
    # print(list(qStr[i].values())[0])
    qString = multReplace(list(qStr[i].values())[0], qStrSub)
    qStrList.append({'name': list(qStr[i].keys())[0], 'queryString': qString})


# =========== fuction definition ==================

def get_var_char_values(d):
    return [obj['VarCharValue'] for obj in d['Data']]


# Query CUR using Athena
# Run query string one by one, and storge query id as new key queryId in the qStrList
def queryCUR(queryList, targetLocation, wait=True):
    client = boto3.client('athena')
    print("Starting query CUR ... ")
    for i in range(len(queryList)):
        print("Query is: " + queryList[i]['queryString'])
        resp = client.start_query_execution(
            QueryString=queryList[i]['queryString'],
            ResultConfiguration={
                'OutputLocation': targetLocation
            })
        queryList[i]['queryId'] = resp['QueryExecutionId']
        print("Query " + queryList[i]['name'] + ' cost, queryId is ' + queryList[i]['queryId'])

    if not wait:
        return resp['QueryExecutionId']
    else:
        client.get_query_execution(
            QueryExecutionId=resp['QueryExecutionId']
        )
        status = 'RUNNING'
        iterations = 360  # 30 mins

    while (iterations > 0):
        iterations = iterations - 1
        response_get_query_details = client.get_query_execution(
            QueryExecutionId=resp['QueryExecutionId']
        )
        status = response_get_query_details['QueryExecution']['Status']['State']
        print("Current Query Execution Status is: " + status)
        if (status == 'FAILED') or (status == 'CANCELLED'):
            failure_reason = response_get_query_details['QueryExecution']['Status']['StateChangeReason']
            print("Query either FAILED or CANCELED, reason is: " + failure_reason)
            return False, False

        elif status == 'QUEUED':
            time.sleep(1)
            print('Waiting 100ms for execution!')
            continue

        elif status == 'SUCCEEDED':
            location = response_get_query_details['QueryExecution']['ResultConfiguration']['OutputLocation']
            print("Query execution succeeded, the query ID is: " + resp['QueryExecutionId'])
            print("Location is: " + location)

            # Function to get output results
            response_query_result = client.get_query_results(
                QueryExecutionId=resp['QueryExecutionId']
            )
            if len(response_query_result['ResultSet']['Rows']) > 1:
                print("Query response result is more than one row, splitting header and rows!")
                header = response_query_result['ResultSet']['Rows'][0]
                rows = response_query_result['ResultSet']['Rows'][1:]

                header = [obj['VarCharValue'] for obj in header['Data']]
                result = [dict(zip(header, get_var_char_values(row))) for row in rows]

                return location, result
            else:
                print("No results found!")
                return location, None
    else:
        time.sleep(5)

    return False


tempPath = '/tmp'
current_date = (datetime.date.today()).strftime('%Y-%m-%d')
file_name = f'ORC-{ENVIRONMENT}-aws-cost-and-usage-report-{current_date}.csv'


# Copy csv query results from s3 to local path
def cpResultsTolocal(bucketName, keyPath, queryList):
    os.chdir(tempPath)
    s3 = boto3.resource('s3')
    for i in range(len(queryList)):
        print("Copy query result: s3://" + bucketName + "/" + keyPath + queryList[i]['queryId'] + ".csv")
        try:
            # os.chdir('/tmp')
            s3.Bucket(bucketName).download_file(keyPath + queryList[i]['queryId'] + '.csv',
                                                file_name)
            is_file_downloaded = os.path.isfile('/tmp/' + file_name)
            print(f"Successfully downloaded the report:  {is_file_downloaded}")
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "404":
                print("The target query result file does not exist.")
            else:
                raise


def sendTestEmail(sesRegion, sesSub, sesSender, sesReceiver, sesReportName, sesBody):
    os.chdir(tempPath)
    print("Sending test email via SES... ")
    client = boto3.client('ses', region_name=sesRegion)
    # Create a multipart/mixed parent container.
    msg = MIMEMultipart('mixed')
    # Add subject, from and to lines.
    msg['Subject'] = sesSub
    msg['From'] = sesSender
    msg['To'] = sesReceiver

    # Define the attachment part and encode it using MIMEApplication.
    att = MIMEApplication(open(sesReportName, 'rb').read())
    # Add a header to tell the email client to treat this part as an attachment,
    # and to give the attachment a name.
    att.add_header('Content-Disposition', 'attachment', filename=os.path.basename(sesReportName))
    # Add the attachment to the parent container.
    msg.attach(att)
    msg.attach(MIMEText(sesBody))
    try:
        # Provide the contents of the email.
        response = client.send_raw_email(
            Source=sesSender,
            Destinations=sesReceiver.split(','),
            RawMessage={
                'Data': msg.as_string()
            }
        )
        return response
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])

    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])


def lambda_handler(event, context):
    queryCUR(qStrList, curOutLoc)
    cpResultsTolocal(curBucket, curKeyPath, qStrList)
    response = sendTestEmail(region, subject, sender, recipient, file_name, bodyText)
    return response
