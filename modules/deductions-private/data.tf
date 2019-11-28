data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_ssm_parameter" "deductions_private_bastion" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/deductions_private_bastion"
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_zone_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/root_zone_id"
}

data "aws_secretsmanager_secret" "mq-admin-username" {
  name = "/nhs/${var.environment}/mq/admin-username"
}

data "aws_secretsmanager_secret" "mq-admin-password" {
  name = "/nhs/${var.environment}/mq/admin-password"
}

data "aws_secretsmanager_secret" "mq-app-username" {
  name = "/nhs/${var.environment}/mq/app-username"
}

data "aws_secretsmanager_secret" "mq-app-password" {
  name = "/nhs/${var.environment}/mq/app-password"
}

data "aws_secretsmanager_secret_version" "mq-admin-username" {
  secret_id = "${data.aws_secretsmanager_secret.mq-admin-username.id}"
}

data "aws_secretsmanager_secret_version" "mq-admin-password" {
  secret_id = "${data.aws_secretsmanager_secret.mq-admin-password.id}"
}

data "aws_secretsmanager_secret_version" "mq-app-username" {
  secret_id = "${data.aws_secretsmanager_secret.mq-app-username.id}"
}

data "aws_secretsmanager_secret_version" "mq-app-password" {
  secret_id = "${data.aws_secretsmanager_secret.mq-app-password.id}"
}