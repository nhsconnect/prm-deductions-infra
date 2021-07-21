data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/NHSDAdminRole"]
    }
  }
}

resource "aws_iam_role" "repo_admin" {
  name = "RepoAdmin"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}


resource "aws_iam_role_policy_attachment" "repo_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.repo_admin.name
}

data "aws_ssm_parameter" "ci_account_id" {
  name = "/repo/ci/user-input/external/aws-account-id"
}

resource "aws_iam_role" "bootstrap_admin" {
  count = var.provision_strict_iam_roles ? 1 : 0
  name = "BootstrapAdmin"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

data "aws_iam_policy_document" "bootstrap_admin_permissions_policy" {
  count = var.provision_strict_iam_roles ? 1 : 0
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
}

resource "aws_iam_role_policy_attachment" "bootstrap_admin" {
  count = var.provision_strict_iam_roles ? 1 : 0
  policy_arn = data.aws_iam_policy_document.bootstrap_admin_permissions_policy[0].id
  role = aws_iam_role.bootstrap_admin[0].name
}

data "aws_caller_identity" "current" {}

