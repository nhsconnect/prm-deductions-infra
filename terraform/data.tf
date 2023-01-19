data "aws_caller_identity" "current" {}
data "aws_ssm_parameter" "sender_cost_report_email_id" {
  name = "/repo/${var.environment}/user-input/sender-cost-report-email-id"
}
data "aws_ssm_parameter" "receiver_cost_report_email_id" {
  name = "/repo/${var.environment}/user-input/receiver-cost-report-email-id"
}
data "aws_ssm_parameter" "support_cost_report_email_id" {
  name = "/repo/${var.environment}/user-input/support-cost-report-email-id"
}