data "aws_ssm_parameter" "splunk_trusted_principal" {
  name = "/repo/user-input/external/splunk-trusted-principal"
}

data "aws_iam_policy_document" "splunk_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = split(",", data.aws_ssm_parameter.splunk_trusted_principal.value)
    }
  }
}

resource "aws_iam_role" "splunk_sqs_forwarder" {
  name               = "SplunkSqsForwarder"
  description        = "Role to allow repo to integrate with splunk"
  assume_role_policy = data.aws_iam_policy_document.splunk_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "splunk_access_policy_attachment" {
  role       = aws_iam_role.splunk_sqs_forwarder.name
  policy_arn = aws_iam_policy.splunk_access_policy.arn
}

resource "aws_iam_policy" "splunk_access_policy" {
  name   = "splunk_access_policy"
  policy = data.aws_iam_policy_document.splunk_access_policy_document.json
}

data "aws_iam_policy_document" "splunk_access_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:DeleteMessage"
    ]
    resources = ["arn:aws:sqs:*:*:*-audit"]
  }
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["*"]
  }
}
