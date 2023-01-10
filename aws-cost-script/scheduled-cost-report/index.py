import os
import yaml
import datetime
import re
import boto3

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
print(os.environ.get('ENVIRONMENT')) ## /home/abc
print(cfg['CUR_Output_Location'])
print(cfg['CUR_DB'])
print(cfg['CUR_Report_Name'])

# Import environment variable defined in Lambda, if it's not existed, use values defined in config.yml
curOutLoc = os.environ.get('CUR_OUTPUT_LOCATION')
if not curOutLoc:
    curOutLoc = cfg['CUR_Output_Location']
curDB = os.environ.get('CUR_DB')
if not curDB:
    curDB = cfg['CUR_DB']
curReportName = os.environ.get('CUR_REPORT_NAME')
if not curReportName:
    curReportName = cfg['CUR_Report_Name']

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
# Query CUR using Athena
# Run query string one by one, and storge query id as new key queryId in the qStrList
def queryCUR(queryList, targetLocation):
    client = boto3.client('athena')
    print("Starting query CUR ... ")
    for i in range(len(queryList)):
        resp = client.start_query_execution(
            QueryString=queryList[i]['queryString'],
            ResultConfiguration={
                'OutputLocation': targetLocation
            })
        queryList[i]['queryId'] = resp['QueryExecutionId']
        print("Query " + queryList[i]['name'] + ' cost, queryId is ' + queryList[i]['queryId'])
    return queryList.values()


# Recursively load query status untill all query status is SUCCEEDED
def checkQueryExecution(queryIdList):
    client = boto3.client('athena')
    resp = client.batch_get_query_execution(QueryExecutionIds=queryIdList)
    query_execution = resp['QueryExecutions']
    unfinishedList = []
    for query in query_execution:
        print(query['QueryExecutionId'], query['Status']['State'])
        if query['Status']['State'] != 'SUCCEEDED':
            unfinishedList.append(query['QueryExecutionId'])
    if (len(unfinishedList) == 0):
        print("All queries are succeed")
        return "Succeed"
    else:
        time.sleep(10)
        checkQueryExecution(unfinishedList)


# Set signal alarm and wait all execution succeed or timeout
def waitQueryExecution(time, qList):
    queryIdList = []
    for i in range(len(qList)):
        queryIdList.append(qList[i]['queryId'])

    def myHandler(signum, frame):
        exit("Timeout - some queries are not succeed. exit!")

    signal.signal(signal.SIGALRM, myHandler)
    signal.alarm(time)
    print("Wait query execution, the expired time is " + str(time) + " seconds")
    checkQueryExecution(queryIdList)
    signal.alarm(0)


def lambda_handler(event, context):
    response = queryCUR(qStrList, curOutLoc)
    waitQueryExecution(queryExpiration, qStrList)
    return {
        'message': response
    }
