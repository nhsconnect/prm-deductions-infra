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
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "ehr-repo-bucket_policy" {
  bucket = aws_s3_bucket.cost_and_usage_bucket.id
  policy = <<POLICY
  {
    "Version": "2008-10-17",
    "Id": "Policy1335892530063",
    "Statement": [
      {
        "Sid": "Stmt1335892150622",
        "Effect": "Allow",
        "Principal": {
        "Service": "billingreports.amazonaws.com"
      },
    "Action": [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy"
    ],
    "Resource": "arn:aws:s3:::pre-prod-cost-and-usage",
    "Condition": {
       "StringEquals": {
         "aws:SourceArn": "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*",
         "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
    }
  },
{
    "Sid": "Stmt1335892526596",
    "Effect": "Allow",
    "Principal": {
    "Service": "billingreports.amazonaws.com"
    },
      "Action": [
    "s3:PutObject"
    ],
    "Resource": "arn:aws:s3:::pre-prod-cost-and-usage/*",
    "Condition": {
    "StringEquals": {
      "aws:SourceArn": "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*",
      "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
}
}
}
]
}
POLICY
}