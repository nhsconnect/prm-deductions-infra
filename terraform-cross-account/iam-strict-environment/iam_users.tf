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

resource "aws_iam_role" "repo_developer" {
  name = "RepoDeveloper"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_policy" "repo_developer_permissions_policy" {
  name = "repo_developer_permissions_policy"
  policy = data.aws_iam_policy_document.repo_developer_permissions.json
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
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/*/user-input/external/*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/*"
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
      "dynamodb:DeleteItem*",
      "dynamodb:CreateTable",
      "dynamodb:TagResource",
      "dynamodb:DeleteTable",
      "dynamodb:List*",
      "dynamodb:Describe*"
    ]
    // FIXME: get table name from ssm
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/prm-deductions-pre-prod-terraform-table"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketVersioning",
      "s3:PutBucketTagging",
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state*"
    ]
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

  statement {
    effect = "Allow"
    actions = [
      "logs:Describe*",
      "logs:List*",
      "ec2:Describe*",
      "ssm:Describe*",
      "ssm:List*",
      "rds:Describe*",
      "rds:List*",
      "route53:List*",
      "acm:Describe*",
      "acm:List*",
      "elasticloadbalancing:Describe*",
      "iam:List*",
      "mq:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/mhs-pre-prod-repo-dns-server"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mhs-pre-prod-repo-dns-server"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetPolicy"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/bootstrap_admin_permissions_policy"]
  }

  statement {
    effect = "Allow"
    actions =  ["route53:GetHostedZone"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions =  ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/CiReadOnly"]
  }
}

data "aws_iam_policy_document" "repo_developer_permissions" {

  statement {
    effect = "Allow"
    actions = ["ssm:PutParameter*"]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/ssh-*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/opentest-ssh-*",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/dns-ssh-*"
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
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem*",
      "dynamodb:List*",
      "dynamodb:Describe*"
    ]
    // FIXME: get table name from ssm
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/prm-deductions-pre-prod-terraform-table"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state/*",
      "arn:aws:s3:::prm-deductions-${var.state_bucket_infix}terraform-state-store/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:Describe*",
      "logs:List*",
      "ec2:Describe*",
      "ssm:Describe*",
      "ssm:List*",
      "rds:Describe*",
      "rds:List*",
      "route53:List*",
      "acm:Describe*",
      "acm:List*",
      "elasticloadbalancing:Describe*",
      "iam:List*",
      "ecr:DescribeRepositories",
      "mq:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/mhs-pre-prod-repo-dns-server"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mhs-pre-prod-repo-dns-server",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/repository-ci-agent"
    ]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetPolicy"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/repo_developer_permissions_policy"
    ]
  }

  statement {
    effect = "Allow"
    actions =  ["route53:GetHostedZone"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions =  ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/CiReadOnly"]
  }
}

resource "aws_iam_role_policy_attachment" "bootstrap_admin" {
  policy_arn = aws_iam_policy.bootstrap_admin_permissions_policy.arn
  role = aws_iam_role.bootstrap_admin.name
}

resource "aws_iam_role_policy_attachment" "repo_developer" {
  policy_arn = aws_iam_policy.repo_developer_permissions_policy.arn
  role = aws_iam_role.repo_developer.name
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ci_account_id" {
  name = "/repo/ci/user-input/external/aws-account-id"
}