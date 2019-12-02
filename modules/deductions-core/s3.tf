resource "aws_s3_bucket" "ehr-repo-bucket" {
  bucket        = "${var.environment}-ehr-repo-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }
}