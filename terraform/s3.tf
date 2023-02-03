locals {
  cost_usage_access_logs_prefix = "access-logs/"
}

resource "aws_s3_bucket" "cost_and_usage_bucket" {
  bucket = "${var.environment}-cost-and-usage"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.cost_and_usage_access_logs.id
    target_prefix = local.cost_usage_access_logs_prefix
  }

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "cost_and_usage_access_logs" {
  bucket = "${var.environment}-cost-and-usage-access-logs"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "cost_usage_permit_developer_to_see_access_logs_policy" {
  count = var.is_restricted_account ? 1 : 0
  bucket = aws_s3_bucket.cost_and_usage_access_logs.id
  policy = jsonencode({
    "Statement": [
      {
        Effect: "Allow",
        Principal:  {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RepoDeveloper"
        },
        Action: ["s3:Get*","s3:ListBucket"],
        Resource: [
          "${aws_s3_bucket.cost_and_usage_access_logs.arn}",
          "${aws_s3_bucket.cost_and_usage_access_logs.arn}/*"
        ],
        Condition: {
          Bool: {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "cost_usage_permit_s3_to_write_access_logs_policy" {
  bucket        = aws_s3_bucket.cost_and_usage_access_logs.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "S3ServerAccessLogsPolicy",
        "Effect": "Allow",
        "Principal": {
          "Service": "logging.s3.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.cost_and_usage_access_logs.arn}/${local.cost_usage_access_logs_prefix}*",
        Condition: {
          Bool: {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}