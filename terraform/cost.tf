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

resource "aws_s3_bucket_policy" "cost_and_usage_bucket_policy" {
  bucket = aws_s3_bucket.cost_and_usage_bucket.id
  policy = jsonencode({
    "Version": "2008-10-17"
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "billingreports.amazonaws.com"
        },
        "Action": [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:PutObject"
        ],
        Resource: [
          aws_s3_bucket.cost_and_usage_bucket.arn,
          "${aws_s3_bucket.cost_and_usage_bucket.arn}/*"
        ]
        Condition: {
          Bool: {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })

}