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
    sid = "GetSSMParameter"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter${data.aws_ssm_parameter.sender_cost_report_email_id.name}",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter${data.aws_ssm_parameter.receiver_cost_report_email_id.name}"
    ]
  }

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

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::dev-cost-and-usage/reports/aws-cost-report/manual-test-results",
      "arn:aws:s3:::dev-cost-and-usage/reports/aws-cost-report/manual-test-results/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::dev-cost-and-usage",
      "arn:aws:s3:::dev-cost-and-usage/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",
      "glue:GetPartitions",
      "glue:GetTable",
      "glue:GetPartition"
    ]
    resources = [
      "arn:aws:athena:eu-west-2:416874859154:workgroup/primary",
      "arn:aws:glue:eu-west-2:416874859154:table/repo-aws-cost/aws_cost_report",
      "arn:aws:glue:eu-west-2:416874859154:database/repo-aws-cost",
      "arn:aws:glue:eu-west-2:416874859154:catalog"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = [
      "arn:aws:ses:eu-west-2:416874859154:identity${data.aws_ssm_parameter.sender_cost_report_email_id.name}",
      "arn:aws:ses:eu-west-2:416874859154:identity${data.aws_ssm_parameter.receiver_cost_report_email_id.name}"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "scheduled-cost-report-policy-attachment" {
  role       = aws_iam_role.scheduled-cost-report-role.name
  policy_arn = aws_iam_policy.scheduled-cost-report-role-policy.arn
}