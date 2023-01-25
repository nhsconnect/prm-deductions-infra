locals {
  receiver_email_address_list = split(",", nonsensitive(data.aws_ssm_parameter.receiver_cost_report_email_id.value))
}


resource "aws_ses_email_identity" "create_cost_report_sender_email_identity" {
  email = data.aws_ssm_parameter.sender_cost_report_email_id.value
}

resource "aws_ses_email_identity" "create_cost_report_receiver_email_ident" {
  for_each = toset(local.receiver_email_address_list)
  email = each.value
}