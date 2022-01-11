data "aws_ssm_parameter" "splunk_trusted_principal" {
  name = "/repo/user-input/external/splunk-trusted-principal"
}

data "aws_iam_policy_document" "splunk_loader_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.splunk_trusted_principal.value]
    }
  }
}

resource "aws_iam_role" "splunkSQSForwarder" {
  name               = "SplunkSQSForwarder"
  description        = "Role to allow repo to integrate with splunk"
  assume_role_policy = data.aws_iam_policy_document.splunk_loader_trust_policy.json
}

