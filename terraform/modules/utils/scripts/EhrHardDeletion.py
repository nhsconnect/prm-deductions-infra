import json
import boto3
import os

def lambda_handler(event, context):
    print("This is the ehr-hard-deletion-lambda!")

    return {
        'statusCode': 200,
        'body': json.dumps('Completed!'),
    }
