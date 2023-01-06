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
    resources = ["arn:aws:sqs:*:*:*-audit", "arn:aws:sqs:*:*:*-audit-uploader"]
  }
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "scheduled-cost-report-role" {
  name = "ScheduledCostReportLambdaExecution"
  description        = "Role to run the scheduled cost report"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "scheduled-cost-report-role-policy" {
  name   = "scheduled_cost_report"
  policy = data.aws_iam_policy_document.scheduled_cost_report_policy_document.json
}

data "aws_iam_policy_document" "scheduled_cost_report_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "scheduled-cost-report-policy-attachment" {
  role       = aws_iam_role.scheduled-cost-report-role.name
  policy_arn = aws_iam_policy.scheduled-cost-report-role-policy.arn
}