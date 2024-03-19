import json
import boto3
import os
import time
import botocore.exceptions
from boto3.dynamodb.conditions import Key

def lambda_handler(event):
    dynamodbTable, inboundConversationId = parse_event(event)
    delete_ehr_from_s3(inboundConversationId)
    verify_database_table_records_deleted(dynamodbTable, inboundConversationId)

def delete_ehr_from_s3(inboundConversationId: str) -> None:
    s3 = boto3.resource('s3')
    try:
        print("Retrieving S3_REPO_BUCKET environment variable")
        s3BucketName = os.environ["S3_REPO_BUCKET"]
        print(f"S3_REPO_BUCKET={s3BucketName}")
        print("Retrieving S3 Bucket")
        repoBucket = s3.Bucket(s3BucketName)
    except KeyError as error:
        print(f"Failed to get S3_REPO_BUCKET environment variable: {error}")
        # Log to splunk for monitoring
    except botocore.exceptions.ClientError as error:
        print(f"Failed to find the S3 Bucket: {error}")
        # Log to splunk for monitoring

    if list(repoBucket.objects.filter(Prefix=inboundConversationId + "/")): # Checks to see objects exist in the S3 Bucket for the given inboundConversationId
        print('EHR found in the S3 Bucket')
        try:
            print("Attempting to delete EHR in the S3 Bucket")
            repoBucket.objects.filter(Prefix=inboundConversationId + "/").delete()
            if not list(repoBucket.objects.filter(Prefix=inboundConversationId + "/")):
                print("EHR has been deleted from the S3 Bucket successfully!")
        except botocore.exceptions.ClientError as error:
            print(f"Failed to delete EHR in the S3 Bucket: {error}")
            # Log to splunk for monitoring
    else:
        print("EHR could not be found in the S3 Bucket")

def parse_event(event):
    print("Parsing event")
    try:
        dynamodbTable = event["Records"][0]["eventSourceARN"].split('/')[1]
        deletedTableRecord = event["Records"][0]["dynamodb"]["OldImage"]
        inboundConversationId = event["Records"][0]["dynamodb"]["Keys"]["InboundConversationId"]["S"]
    except KeyError as error:
        print(f"Could not find the relevant event key(s): {error}")
        # Log to splunk for monitoring

    print(f"InboundConversationId: {inboundConversationId}, DynamoDB Table: {dynamodbTable}, Deleted Conversation: {str(deletedTableRecord)}")
    return dynamodbTable, inboundConversationId

def verify_database_table_records_deleted(dynamodbTable: str, inboundConversationId: str) -> None:
    dynamodb = boto3.resource('dynamodb')
    print("Retrieving DynamoDB table")
    ehrTrasferTrackerTable = dynamodb.Table(dynamodbTable)

    print("Verifying all database records have been deleted")
    try:
        queryResponse = ehrTrasferTrackerTable.query(KeyConditionExpression=Key("InboundConversationId").eq(inboundConversationId))
    except botocore.exceptions.ClientError as error:
        print(f"Failed to query the dynamodb table: {error}")

    if queryResponse["Count"] == 0:
        print("All database records have been deleted")
    else:
        print(f"Number of database records still existing: {str(queryResponse['Count'])}")
        raise Exception(f"[WTF] - Database records still exist for InboundConversationId: {inboundConversationId}")
        # Log to splunk for monitoring