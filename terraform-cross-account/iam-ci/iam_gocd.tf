data "aws_iam_policy_document" "gocd_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.dev_account_id.value}:role/repository-ci-agent",   # dev environment (in dev account)
        "arn:aws:iam::${data.aws_caller_identity.ci_account.account_id}:role/gocd_agent-prod",     # test environment (in ci account)
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/repository-ci-agent",   # pre-prod environment (in pre-prod account)
        # more accounts will follow for other environments...
      ]
    }
  }
}

resource "aws_iam_role" "ci_agent" {
  name = "repository-ci-agent"
  assume_role_policy = data.aws_iam_policy_document.gocd_trust_policy.json
}

resource "aws_iam_instance_profile" "ci_agent" {
  name = "repository-ci-agent"
  role = aws_iam_role.ci_agent.name
}

resource "aws_iam_role_policy_attachment" "ci_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.ci_agent.name
}

resource "aws_iam_role" "ci_cross_agent" {
  name = "repository-cross-ci-agent"
  assume_role_policy = data.aws_iam_policy_document.gocd_trust_policy.json
}

resource "aws_iam_instance_profile" "ci_cross_agent" {
  name = "repository-cross-ci-agent"
  role = aws_iam_role.ci_cross_agent.name
}

resource "aws_iam_role_policy_attachment" "ci_cross_agent" {
  policy_arn = aws_iam_policy.ci_cross_agent.arn
  role = aws_iam_role.ci_cross_agent.name
}

resource "aws_iam_policy" "ci_cross_agent" {
  name = "CiCrossAgent"
  policy = data.aws_iam_policy_document.ci_cross_account.json
}

data "aws_iam_policy_document" "ci_cross_account" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetPolicy"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeRouteTables",
      "ec2:DescribeVpcPeeringConnections"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListVPCAssociationAuthorizations",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByVPC"
    ]
    resources = ["*"]
  }
}
