# TODO: PRMT-4648 - THIS IS A ONE-TIME MIGRATION SCRIPT LAMBDA. DELETE THIS .TF FILE AFTER USAGE!

import re
import os
import boto3
import botocore

from dateutil import parser
from zoneinfo import ZoneInfo
from typing import Optional
from dataclasses import dataclass, asdict, field

OLD_TABLE_NAME = os.environ["OLD_TABLE"]
NEW_TABLE_NAME = os.environ["NEW_TABLE"]

dynamo_client = boto3.client("dynamodb", region_name="eu-west-2")


@dataclass
class OldConversation:
    """ Represents the old DynamoDB table structure. """

    # Fields we know will be present.
    conversation_id: str
    nhs_number: str
    source_gp: str
    state: str

    # Fields which may be absent.
    nems_message_id: Optional[str] = field(default=None)
    date_time: Optional[str] = field(default=None)
    created_at: Optional[str] = field(default=None)
    last_updated_at: Optional[str] = field(default=None)


@dataclass
class NewConversation:
    """ Represents the new DynamoDB table structure. """

    # Fields we know will be present.
    inbound_conversation_id: str
    nhs_number: str
    source_gp: str
    transfer_status: str
    layer: str = "CONVERSATION"

    # Fields which may be absent.
    failure_code: Optional[str] = field(default=None)
    nems_message_id: Optional[str] = field(default=None)
    created_at: Optional[str] = field(default=None)
    updated_at: Optional[str] = field(default=None)


def snake_to_pascal(name: str) -> str:
    return ''.join(word.capitalize() for word in name.split('_'))


def _get_new_conversations(old_conversations: list[OldConversation]) -> list[NewConversation]:
    new_conversations = []

    for old_conversation in old_conversations:
        new_conversation = NewConversation(
            inbound_conversation_id=old_conversation.conversation_id.upper(),
            nhs_number=old_conversation.nhs_number,
            source_gp=old_conversation.source_gp,
            transfer_status=_get_new_state(old_conversation.state),
            failure_code=_get_failure_code(old_conversation.state),
            nems_message_id=old_conversation.nems_message_id,
            created_at=_get_new_datetime(old_conversation.created_at),
            updated_at=_get_new_datetime(old_conversation.last_updated_at)
        )

        if new_conversation.created_at is None and new_conversation.updated_at is None:
            old_datetime = old_conversation.date_time
            new_conversation.created_at = _get_new_datetime(old_datetime)
            new_conversation.updated_at = _get_new_datetime(old_datetime)

        new_conversations.append(new_conversation)

    return new_conversations


def _get_new_state(old_state: str) -> str:
    state_mapping = {
        'EHR_REQUEST_SENT': 'INBOUND_REQUEST_SENT',
        'EHR_TRANSFER_FAILED': 'INBOUND_FAILED',
        'EHR_TRANSFER_TIMEOUT': 'INBOUND_TIMEOUT',
        'EHR_TRANSFER_TO_REPO_COMPLETE': 'INBOUND_COMPLETE',
        'LARGE_EHR_CONTINUE_REQUEST_SENT': 'INBOUND_CONTINUE_REQUEST_SENT',
        'TRANSFER_TO_REPO_STARTED': 'INBOUND_STARTED'
    }

    return state_mapping.get(old_state.split(':')[1])


def _get_failure_code(old_state: str) -> str:
    state_segments = old_state.split(':')
    if len(state_segments) > 2:
        return state_segments[2]


def _get_new_datetime(old_datetime: str):
    if old_datetime is not None:
        target_timezone = ZoneInfo('Europe/London')
        formatted_datetime = old_datetime.split('.')[0]
        parsed_datetime = parser.parse(formatted_datetime).astimezone(target_timezone).isoformat()

        return parsed_datetime


def _get_old_conversations() -> list[OldConversation]:
    found_conversations = []

    scan_expression = """
    conversation_id, nhs_number, source_gp,
    #transfer_status, nems_message_id, date_time,
    created_at, last_updated_at
    """

    dynamo_paginator = dynamo_client.get_paginator('scan')
    dynamo_response = dynamo_paginator.paginate(
        TableName=OLD_TABLE_NAME,
        Select='SPECIFIC_ATTRIBUTES',
        ProjectionExpression=scan_expression,
        ExpressionAttributeNames={'#transfer_status': 'state'},
        ReturnConsumedCapacity='NONE',
        ConsistentRead=True
    )

    for page in dynamo_response:
        for page_item in page["Items"]:
            found_conversation = OldConversation(**{
                key: value.get('S', value.get('N')) for key, value in page_item.items()
            })

            found_conversations.append(found_conversation)

    return found_conversations


def _persist_new_conversations(new_conversations: list[NewConversation]) -> None:
    for new_conversation in new_conversations:
        dynamo_client.put_item(
            TableName=NEW_TABLE_NAME,
            Item={
                snake_to_pascal(k): {'S': str(v)} for k, v in asdict(new_conversation).items() if v is not None
            }
        )


def _migrate() -> dict:
    old_conversations = _get_old_conversations()
    new_conversations = _get_new_conversations(old_conversations)
    _persist_new_conversations(new_conversations)

    print(new_conversations)

    return {
        "status": "success"
    }


def lambda_handler(event, context) -> dict:
    response = _migrate()

    return {
        "statusCode": 200,
        "body": response
    }
