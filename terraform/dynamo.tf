module "ehr_transfer_tracker_dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.0"

  name      = "${var.environment}-ehr-transfer-tracker"
  hash_key  = "InboundConversationId"
  range_key = "Layer"
  global_secondary_indexes = [
    {
      name            = "NhsNumberSecondaryIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    },
    {
      name            = "OutboundConversationIdSecondaryIndex"
      hash_key        = "OutboundConversationId"
      projection_type = "ALL"
    }
  ]

  attributes = [
    {
      "name" : "InboundConversationId",
      "type" : "S"
    },
    {
      "name" : "Layer",
      "type" : "S"
    },
    {
      "name" : "NhsNumber",
      "type" : "S"
    },
    {
      "name" : "OutboundConversationId",
      "type" : "S"
    }
  ]

  deletion_protection_enabled    = true
  point_in_time_recovery_enabled = true
  server_side_encryption_enabled = true

  providers = {
    aws = aws.latest
  }
}