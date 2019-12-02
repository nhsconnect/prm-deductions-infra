data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_zone_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/root_zone_id"
}

data "aws_secretsmanager_secret" "db-username" {
  name = "/nhs/${var.environment}/db/db-username"
}

data "aws_secretsmanager_secret" "db-password" {
  name = "/nhs/${var.environment}/db/db-password"
}

data "aws_secretsmanager_secret_version" "db-password" {
  secret_id = "${data.aws_secretsmanager_secret.db-password.id}"
}

data "aws_secretsmanager_secret_version" "db-username" {
  secret_id = "${data.aws_secretsmanager_secret.db-username.id}"
}