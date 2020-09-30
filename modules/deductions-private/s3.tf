resource "aws_s3_bucket" "gp2gp-bucket" {
  bucket        = "${var.environment}-gp2gp-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
