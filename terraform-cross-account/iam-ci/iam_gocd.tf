data "aws_iam_policy_document" "gocd_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.dev_account_id.value}:role/repository-ci-agent",
        "arn:aws:iam::${data.aws_ssm_parameter.test_account_id.value}:role/repository-ci-agent",
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/repository-ci-agent",
        "arn:aws:iam::${data.aws_ssm_parameter.dev_account_id.value}:role/Deployer",
        "arn:aws:iam::${data.aws_ssm_parameter.test_account_id.value}:role/Deployer",
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/Deployer",
        # prod to be added...
      ]
    }
  }
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
  policy_arn = aws_iam_policy.ci_read_only.arn
  role = aws_iam_role.ci_cross_agent.name
}

resource "aws_iam_role" "ci_to_env_linker" {
  name = "CiToEnvLinker"
  assume_role_policy = data.aws_iam_policy_document.gocd_trust_policy.json
}

resource "aws_iam_instance_profile" "ci_to_env_linker" {
  name = "CiToEnvLinker"
  role = aws_iam_role.ci_to_env_linker.name
}

resource "aws_iam_role_policy_attachment" "ci_to_env_linker" {
  policy_arn = aws_iam_policy.ci_read_only.arn
  role = aws_iam_role.ci_to_env_linker.name
}

resource "aws_iam_role_policy_attachment" "ci_to_env_linker_ssm" {
  policy_arn = aws_iam_policy.cross_ci_ssm.arn
  role = aws_iam_role.ci_to_env_linker.name
}

resource "aws_iam_role_policy_attachment" "cross_ci_ssm" {
  policy_arn = aws_iam_policy.cross_ci_ssm.arn
  role = aws_iam_role.ci_cross_agent.name
}

resource "aws_iam_policy" "cross_ci_ssm" {
  name = "cross-ci-ssm"
  policy = data.aws_iam_policy_document.cross_ci_ssm.json
}

data "aws_iam_policy_document" "cross_ci_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["arn:aws:ssm:*:327778747031:parameter/*"]
  }
}

resource "aws_iam_role_policy_attachment" "cross_ci_write" {
  policy_arn = aws_iam_policy.cross_ci_write.arn
  role = aws_iam_role.ci_cross_agent.name
}

resource "aws_iam_role_policy_attachment" "ci_to_env_linker_write" {
  policy_arn = aws_iam_policy.cross_ci_write.arn
  role = aws_iam_role.ci_to_env_linker.name
}

resource "aws_iam_policy" "cross_ci_write" {
  name = "repository-cross-ci-write"
  policy = data.aws_iam_policy_document.cross_ci_write.json
}

data "aws_iam_policy_document" "cross_ci_write" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AcceptVpcPeeringConnection",
      "ec2:CreateRoute",
      "ec2:CreateTags",
      "ec2:DeleteRoute",
      "ec2:ReplaceRoute"
    ]
    resources = ["arn:aws:ec2:*:327778747031:vpc*",
                "arn:aws:ec2:*:327778747031:route-table/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:DisassociateVPCFromHostedZone",
      "route53:AssociateVPCWithHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:DeleteVPCAssociationAuthorization",
      "route53:CreateVPCAssociationAuthorization"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
}
