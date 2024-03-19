import json
import boto3
import os
import time
from boto3.dynamodb.conditions import Key

def lambda_handler(event, context):
    dynamodbTable, inboundConversationId = parseEvent(event)
    deleteEhrFromS3(inboundConversationId)
    verify_database_table_records_deleted(dynamodbTable, inboundConversationId)

def deleteEhrFromS3(inboundConversationId):
    s3 = boto3.resource('s3')
    try:
        print("Retrieving S3_REPO_BUCKET environment variable")
        s3BucketName = os.environ["S3_REPO_BUCKET"]
        print("S3_REPO_BUCKET=" + s3BucketName)
        print("Retrieving S3 Bucket")
        repoBucket = s3.Bucket(s3BucketName)
    except KeyError as error:
        print("Failed to get S3_REPO_BUCKET environment variable: " + error)
        # Log to splunk for monitoring
    except Exception as error:
        print("Failed to find the S3 Bucket: " + error)
        # Log to splunk for monitoring

    if any(True for _ in repoBucket.objects.filter(Prefix=inboundConversationId + "/")): # Checks to see objects exist in the S3 Bucket for the given inboundConversationId
        print('EHR found in the S3 Bucket')
        try:
            print("Attempting to delete EHR in the S3 Bucket")
            repoBucket.objects.filter(Prefix=inboundConversationId + "/").delete()
            if all(False for _ in repoBucket.objects.filter(Prefix=inboundConversationId + "/")):
                print("EHR has been deleted from the S3 Bucket successfully!")
        except Exception as error:
            print("Failed to delete EHR in the S3 Bucket: " + error)
            # Log to splunk for monitoring
    else:
        print("EHR could not be found in the S3 Bucket")

def parseEvent(event):
    print("Parsing event")
    try:
        dynamodbTable = event["Records"][0]["eventSourceARN"].split('/')[1]
        deletedTableRecord = event["Records"][0]["dynamodb"]["OldImage"]
        inboundConversationId = event["Records"][0]["dynamodb"]["Keys"]["InboundConversationId"]["S"]
    except KeyError as error:
        print("Could not find the relevant event key(s): " + error)
        # Log to splunk for monitoring

    print(
        "InboundConversationId: " + inboundConversationId +
        ", DynamoDB Table: " + dynamodbTable +
        ", Deleted Conversation: " + str(deletedTableRecord)
    )
    return dynamodbTable, inboundConversationId

def verify_database_table_records_deleted(dynamodbTable: str, inboundConversationId: str) -> None:
    dynamodb = boto3.resource('dynamodb')
    print("Retrieving DynamoDB table")
    ehrTrasferTrackerTable = dynamodb.Table(dynamodbTable)
    print("Verifying all database records have been deleted")
    queryResponse = ehrTrasferTrackerTable.query(KeyConditionExpression=Key("InboundConversationId").eq(inboundConversationId))

    if queryResponse["Count"] == 0:
        print("All database records have been deleted")
    else:
        print("Number of database records still existing: " + str(queryResponse["Count"]))
        raise Exception("[WTF] - Database records still exist for InboundConversationId: " + inboundConversationId)
        # Log to splunk for monitoring