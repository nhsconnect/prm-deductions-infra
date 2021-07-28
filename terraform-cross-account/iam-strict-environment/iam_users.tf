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
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/prm-deductions-${var.environment}-terraform-table"]
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
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/mhs-${var.environment}-repo-dns-server"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"]
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

  statement {
    effect = "Allow"
    actions =  ["ec2:ExportClientVpnClientConfiguration"]
    resources = ["arn:aws:ec2:eu-west-2:${data.aws_ssm_parameter.ci_account_id.value}:client-vpn-endpoint/${data.aws_ssm_parameter.client-vpn-endpoint-id.value}"]
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
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/prm-deductions-${var.environment}-terraform-table"]
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
      "mq:Describe*",
      "ecs:DescribeTaskDefinition",
      "ecr:ListTagsForResource"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/mhs-${var.environment}-repo-dns-server",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/repository-ci-agent"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*",
      "arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/RepoAdmin"
    ]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetPolicy", "iam:GetPolicyVersion"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/repo_developer_permissions_policy",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment}*-ssm",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment}*-ecr",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment}*-logs",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment}*-s3*",

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

  statement{
    effect = "Allow"
    actions = ["ecs:DescribeServices",]
    resources = ["arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/${var.environment}*-ecs-cluster/${var.environment}*-service"]
  }

  statement{
    effect = "Allow"
    actions = ["kms:GetKeyRotationStatus",
              "kms:GetKeyPolicy",
              "kms:ListResourceTags",
              "kms:Describe*"]
    resources = ["arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/*"]
  }

  statement{
    effect = "Allow"
    actions = ["ecs:DescribeClusters"]
    resources = ["arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster/${var.environment}*-ecs-cluster"]
  }

  statement{
    effect = "Allow"
    actions = ["cloudwatch:List*","cloudwatch:Describe*"]
    resources = ["arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"]
  }

  statement{
    effect = "Allow"
    actions = ["s3:List*","s3:Get*"]
    resources = ["arn:aws:s3:::${var.environment}-ehr-repo-bucket"]
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

data "aws_ssm_parameter" "client-vpn-endpoint-id" {
  name = "/repo/${var.environment}/output/prm-deductions-infra/client-vpn-endpoint-id"
}

