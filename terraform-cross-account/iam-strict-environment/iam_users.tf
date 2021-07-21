data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/NHSDAdminRole"]
    }
  }
}

resource "aws_iam_role" "bootstrap_admin" {
  name = "BootstrapAdmin"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_policy" "bootstrap_admin_permissions_policy" {
  name = "bootstrap_admin_permissions_policy"
  policy = data.aws_iam_policy_document.bootstrap_admin_permissions.json
}

data "aws_iam_policy_document" "bootstrap_admin_permissions" {
  statement {
    effect = "Allow"
    actions = ["ssm:PutParameter*"]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/*/user-input/external/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = ["ssm:GetParameter*"]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/*/output/*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/output/*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/*/user-input/*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem*",
      "dynamodb:GetItem*",
      "dynamodb:DeleteItem*"
    ]
    // FIXME: get table name from ssm
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/prm-deductions-pre-prod-terraform-table"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state/*",
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state-store/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "bootstrap_admin" {
  policy_arn = aws_iam_policy.bootstrap_admin_permissions_policy.arn
  role = aws_iam_role.bootstrap_admin.name
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ci_account_id" {
  name = "/repo/ci/user-input/external/aws-account-id"
}