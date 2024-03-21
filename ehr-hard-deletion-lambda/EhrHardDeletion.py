import boto3
import botocore.exceptions
import logging
import os

from boto3.dynamodb.conditions import Key

logger = logging.getLogger(__name__)


def lambda_handler(event) -> None:
    table_name, inbound_conversation_id = parse_event(event)
    delete_ehr_from_s3(inbound_conversation_id)
    verify_database_table_records_deleted(table_name, inbound_conversation_id)


def parse_event(event) -> tuple[str, str]:
    logger.info("Parsing event")
    try:
        table_name = event["Records"][0]["eventSourceARN"].split('/')[1]
        deleted_table_record = event["Records"][0]["dynamodb"]["OldImage"]
        inbound_conversation_id = event["Records"][0]["dynamodb"]["Keys"]["InboundConversationId"]["S"]
    except KeyError as error:
        logger.error(f"Could not find the relevant event key(s): {error}")
        # TODO: Log to splunk for monitoring

    logger.info(f"InboundConversationId: {inbound_conversation_id}, DynamoDB Table: {table_name}, Deleted Conversation: {str(deleted_table_record)}")

    return table_name, inbound_conversation_id


def delete_ehr_from_s3(inbound_conversation_id: str) -> None:
    s3 = boto3.resource('s3')
    try:
        s3_bucket_name = os.environ["S3_REPO_BUCKET"]
        repo_bucket = s3.Bucket(s3_bucket_name)

        if list(repo_bucket.objects.filter(Prefix=inbound_conversation_id + "/")):
            logger.info("Attempting to delete EHR in the S3 Bucket")
            repo_bucket.objects.filter(Prefix=inbound_conversation_id + "/").delete()
            if not list(repo_bucket.objects.filter(Prefix=inbound_conversation_id + "/")):
                logger.info("EHR has been deleted from the S3 Bucket successfully!")
        else:
            logger.error("EHR could not be found in the S3 Bucket")
    except KeyError as error:
        logger.error(f"Failed to get S3_REPO_BUCKET environment variable: {error}")
        # TODO: Log to splunk for monitoring
    except botocore.exceptions.ClientError as error:
        logger.error(f"Exception while interacting with S3: {error}")
        # TODO: Log to splunk for monitoring


def verify_database_table_records_deleted(table_name: str, inbound_conversation_id: str) -> None:
    dynamo_db = boto3.resource('dynamodb')
    ehr_transfer_tracker_table = dynamo_db.Table(table_name)

    try:
        logger.info("Verifying all database records have been deleted")
        key_condition_expression = Key("InboundConversationId").eq(inbound_conversation_id)
        query_response = ehr_transfer_tracker_table.query(KeyConditionExpression=key_condition_expression)

        if query_response["Count"] == 0:
            logger.info("All database records have been deleted")
        else:
            logger.critical(
                f"Database records still exist ({str(query_response['Count'])}) for InboundConversationId: {inbound_conversation_id}")
            # TODO: Log to splunk for monitoring
    except botocore.exceptions.ClientError as error:
        logger.error(f"Failed to query the dynamodb table: {error}")
        # TODO: Log to splunk for monitoring
