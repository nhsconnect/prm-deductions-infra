resource "aws_sns_topic" "alarm_notifications" {
  name = "${var.environment}-alarm-notifications-sns-topic"
  kms_master_key_id = aws_kms_key.alarm_notification.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Action": "sns:Publish",
        "Resource": [aws_sns_topic.alarm_notifications.arn],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-alarm-notifications-sns-topic"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_key" "alarm_notification" {
  description = "Custom KMS Key to enable server side encryption for alarm notifications"
  policy      = data.aws_iam_policy_document.alarm_notification_kms_key_policy_doc.json
  enable_key_rotation = true

  tags = {
    Name        = "${var.environment}-alarm_notification-kms-key"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "alarm_notification_encryption" {
  name          = "alias/alarm-notification-encryption-kms-key"
  target_key_id = aws_kms_key.alarm_notification.id
}

data "aws_iam_policy_document" "alarm_notification_kms_key_policy_doc" {
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