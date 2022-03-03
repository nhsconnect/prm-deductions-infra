resource "aws_iam_policy" "s3_deny_content_access" {
  name = "s3_deny_content_access"
  policy = data.aws_iam_policy_document.s3_deny_content_access.json
}

resource "aws_iam_policy" "s3_allow_terraform_state_content_access" {
  name = "s3_deny_content_access"
  policy = data.aws_iam_policy_document.s3_allow_terraform_state_content_access.json
}

resource "aws_iam_policy" "s3_allow_ehr_repo_content_access" {
  name = "s3_allow_ehr_repo_content_access"
  policy = data.aws_iam_policy_document.s3_allow_ehr_repo_content_access.json
}

data "aws_iam_policy_document" "s3_deny_content_access" {
  statement {
    sid = "S3DenyContentAccess"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::*/*"]
  }
}

data "aws_iam_policy_document" "s3_allow_terraform_state_content_access" {
  statement {
    sid = "S3AllowTerraformStateContentAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state/*",
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state-store/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_allow_ehr_repo_content_access" {
  statement {
    sid = "S3AllowEhrRepoBucketReadAccess"
    effect = "Allow"
    actions = [
        "s3:List*",
        "s3:Get*"
    ]
    resources = ["arn:aws:s3:::${var.environment}-ehr-repo-bucket"]
  }
}

