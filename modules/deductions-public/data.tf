data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_ssm_parameter" "deductions_private_bastion" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/deductions_private_bastion"
}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "portal_acm_certificate" {
  domain   = "${var.environment}.patient-deductions.nhs.uk"
  statuses = ["ISSUED"]
}