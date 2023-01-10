resource "aws_lambda_function" "scheduled_cost_report" {
  filename      = var.schedule_cost_report_lambda_zip
  function_name = "${var.environment}-schedule-cost-report-lambda"
  role          = aws_iam_role.scheduled-cost-report-role.arn
  handler       = "index.lambda_handler"
  source_code_hash = filebase64sha256(var.schedule_cost_report_lambda_zip)
  runtime       = "python3.8"
  timeout       = 15
  memory_size   = 448
  tags = {
    Environment = var.environment
    CreatedBy   = var.repo_name
  }
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}