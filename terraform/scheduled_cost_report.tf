resource "aws_lambda_function" "generate_cost_report_lambda" {
  filename      = var.generate_cost_report_lambda_zip
  function_name = "${var.environment}-generate-cost-report-lambda"
  role          = aws_iam_role.generate-cost-report-role.arn
  handler       = "index.lambda_handler"
  source_code_hash = filebase64sha256(var.generate_cost_report_lambda_zip)
  runtime       = "python3.8"
  timeout       = 15
  memory_size   = 448
  tags = {
    Environment = var.environment
    CreatedBy   = var.repo_name
  }
  environment {
    variables = {
      ENVIRONMENT = var.environment,
      SENDER_EMAIL_SSM_PARAMETER = data.aws_ssm_parameter.sender_cost_report_email_id.name,
      RECEIVER_EMAIL_SSM_PARAMETER = data.aws_ssm_parameter.receiver_cost_report_email_id.name
    }
  }
}