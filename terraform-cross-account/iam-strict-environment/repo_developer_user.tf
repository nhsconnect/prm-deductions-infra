resource "aws_iam_role" "repo_developer" {
  name = "RepoDeveloper"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_policy" "repo_developer_permissions_policy" {
  name = "repo_developer_permissions_policy"
  policy = data.aws_iam_policy_document.repo_developer_permissions.json
}

data "aws_iam_policy_document" "repo_developer_permissions" {

  statement {
    effect = "Allow"
    actions = ["ssm:PutParameter*"]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/repo/user-input/ssh-*",
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
      "dynamodb:Describe*",
      "dynamodb:List*"
    ]
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/${var.environment}-repo-mhs*"]
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
      "ecs:Describe*",
      "ecr:ListTagsForResource",
      "elasticache:Describe*",
      "elasticache:List*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["iam:GetInstanceProfile"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*",
      "arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/RepoAdmin",
      "arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/CiReadOnly"
    ]
  }

  statement {
    effect = "Allow"
    actions =  ["iam:GetPolicy", "iam:GetPolicyVersion"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*"]
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
    resources = ["arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:cluster/${var.environment}*"]
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

  statement{
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:/repo/${var.environment}/user-input/*"]
  }

}


resource "aws_iam_role_policy_attachment" "repo_developer" {
  policy_arn = aws_iam_policy.repo_developer_permissions_policy.arn
  role = aws_iam_role.repo_developer.name
}
