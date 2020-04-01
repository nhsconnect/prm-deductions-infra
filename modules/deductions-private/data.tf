data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/dev-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_zone_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/root_zone_id"
}

data "aws_ssm_parameter" "private_zone_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/${var.environment}/private_root_zone_id"
}

data "aws_ssm_parameter" "mq-admin-username" {
  name = "/nhs/${var.environment}/mq/admin-username"
}

data "aws_ssm_parameter" "mq-admin-password" {
  name = "/nhs/${var.environment}/mq/admin-password"
}

data "aws_ssm_parameter" "mq-app-username" {
  name = "/nhs/${var.environment}/mq/app-username"
}

data "aws_ssm_parameter" "mq-app-password" {
  name = "/nhs/${var.environment}/mq/app-password"
}

data "aws_ssm_parameter" "vpn_sg" {
  name = "/nhs/${var.environment}/vpn_sg"
}

data "aws_ssm_parameter" "db-username" {
  name = "/nhs/${var.environment}/state-db/db-username"
}

data "aws_ssm_parameter" "db-password" {
  name = "/nhs/${var.environment}/state-db/db-password"
}
