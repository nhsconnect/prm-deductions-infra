data "aws_iam_policy_document" "gocd_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.dev_account_id.value}:role/repository-ci-agent",   # dev environment (in dev account)
        "arn:aws:iam::${data.aws_caller_identity.ci_account.account_id}:role/gocd_agent-prod"     # test environment (in ci account)
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
