data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_zone_id" {
  name = "/repo/prm-deductions-base-infra/output/root-zone-id"
}

data "aws_ssm_parameter" "db-username" {
  name = "/repo/${var.environment}/user-input/db-username"
}

data "aws_ssm_parameter" "db-password" {
  name = "/repo/${var.environment}/user-input/db-password"
}