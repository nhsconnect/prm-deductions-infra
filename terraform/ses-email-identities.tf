locals {
  receiver_email_address_list = split(",", nonsensitive(data.aws_ssm_parameter.receiver_cost_report_email_id.value))
  support_email_address_list = split(",", nonsensitive(data.aws_ssm_parameter.support_cost_report_email_id.value))
}


resource "aws_ses_email_identity" "create_cost_report_sender_email_identity" {
  email = data.aws_ssm_parameter.sender_cost_report_email_id.value
}

resource "aws_ses_email_identity" "create_cost_report_receiver_email_identity" {
  for_each = toset(local.receiver_email_address_list)
  email = each.value
}

resource "aws_ses_email_identity" "create_cost_support_email_identity" {
  for_each = toset(local.support_email_address_list)
  email = each.value
}