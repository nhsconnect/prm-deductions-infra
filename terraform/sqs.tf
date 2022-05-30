resource "aws_sqs_queue" "splunk_audit_uploader" {
  name                       = "${var.environment}-splunk-audit-uploader"
  message_retention_seconds  = 1209600
  kms_master_key_id = aws_kms_key.splunk_audit_uploader.id

  tags = {
    Name = "${var.environment}-splunk-audit-uploader"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_key" "splunk_audit_uploader" {
  description = "Custom KMS Key to enable server side encryption for Splunk audit uploader SQS queue"
  policy      = data.aws_iam_policy_document.kms_key_policy_doc.json
  enable_key_rotation = true

  tags = {
    Name        = "${var.environment}-splunk-audit-uploader-queue-encryption-kms-key"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "splunk_audit_uploader_encryption" {
  name          = "alias/splunk-audit-uploader-encryption-kms-key"
  target_key_id = aws_kms_key.splunk_audit_uploader.id
}

data "aws_iam_policy_document" "kms_key_policy_doc" {
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

  statement {
    effect = "Allow"

    principals {
      identifiers = ["cloudwatch.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["*"]
  }
}