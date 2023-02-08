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

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "${var.environment}-repo-load-balancer-access-logs"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "alb_access_logs_policy" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.allow_load_balancers_to_publish_to_access_logs_s3_bucket.json
}

data "aws_iam_policy_document" "allow_load_balancers_to_publish_to_access_logs_s3_bucket" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::652711504416:root"]
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_access_logs.arn}/*"]
  }
}

resource "aws_ssm_parameter" "alb_access_logs_s3_bucket_id" {
  value = aws_s3_bucket.alb_access_logs.id
  type = "String"
  description = "Exported this bucket id so each alb in different git repos can configure logs"
  name = "/repo/${var.environment}/output/${var.repo_name}/alb-access-logs-s3-bucket-id"
}