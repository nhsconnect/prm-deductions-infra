resource "aws_s3_bucket" "gp2gp-bucket" {
  bucket        = "${var.environment}-gp2gp-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}
