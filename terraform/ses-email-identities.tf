resource "aws_ses_email_identity" "create_cost_report_sender_email_identity" {
  email = data.aws_ssm_parameter.sender_cost_report_email_id.value
}