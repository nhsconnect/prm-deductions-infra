data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/NHSDAdminRole",
        "arn:aws:iam::${data.aws_ssm_parameter.nhsd_identities_account_id.value}:root"
      ]
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ci_account_id" {
  name = "/repo/ci/user-input/external/aws-account-id"
}

data "aws_ssm_parameter" "nhsd_identities_account_id" {
  name = "/repo/nhsd-identities/user-input/external/aws-account-id"
}

data "aws_ssm_parameter" "client-vpn-endpoint-id" {
  name = "/repo/${var.environment}/output/prm-deductions-infra/client-vpn-endpoint-id"
}
