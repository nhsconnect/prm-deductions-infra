resource "aws_sqs_queue" "splunk_audit_uploader" {
  name                       = "${var.environment}-splunk-audit-uploader"
  message_retention_seconds  = 1209600
  kms_master_key_id = aws_kms_key.splunk_audit_uploader_kms_key.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.splunk_audit_uploader_dlq.arn
    maxReceiveCount     = 4
  })

  tags = {
    Name = "${var.environment}-splunk-audit-uploader"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "splunk_audit_uploader_queue_arn" {
  name =  "/repo/${var.environment}/output/${var.repo_name}/splunk-audit-uploader-queue-arn"
  type  = "String"
  value = aws_sqs_queue.splunk_audit_uploader.arn
}

resource "aws_sqs_queue" "splunk_audit_uploader_dlq" {
  name                       = "${var.environment}-splunk-audit-uploader-dlq"
  message_retention_seconds  = 1209600
  kms_master_key_id = aws_kms_key.splunk_audit_uploader_kms_key.id

  tags = {
    Name = "${var.environment}-splunk-audit-uploader-dlq"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_key" "splunk_audit_uploader_kms_key" {
  description = "Custom KMS Key to enable server side encryption for Splunk audit uploader SQS queue"
  policy      = data.aws_iam_policy_document.splunk_audit_uploader_kms_key_policy_doc.json
  enable_key_rotation = true

  tags = {
    Name        = "${var.environment}-splunk-audit-uploader-queue-encryption-kms-key"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "splunk_audit_uploader_key_alias" {
  name          = "alias/splunk-audit-uploader-encryption-kms-key"
  target_key_id = aws_kms_key.splunk_audit_uploader_kms_key.id
}

resource "aws_ssm_parameter" "splunk_audit_uploader_kms_key" {
  name =  "/repo/${var.environment}/output/${var.repo_name}/splunk-audit-uploader-kms-key"
  type  = "String"
  value = aws_kms_key.splunk_audit_uploader_kms_key.id
}

data "aws_iam_policy_document" "splunk_audit_uploader_kms_key_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["*"]
  }
}