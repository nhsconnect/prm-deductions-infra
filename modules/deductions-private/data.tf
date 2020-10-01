data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "root_zone_id" {
  name = "/repo/output/prm-deductions-base-infra/root-zone-id"
}

data "aws_ssm_parameter" "mq-admin-username" {
  name = "/repo/${var.environment}/user-input/mq-admin-username"
}

data "aws_ssm_parameter" "mq-admin-password" {
  name = "/repo/${var.environment}/user-input/mq-admin-password"
}

data "aws_ssm_parameter" "mq-app-username" {
  name = "/repo/${var.environment}/output/${var.repo_name}/mq-app-username"
}

data "aws_ssm_parameter" "mq-app-password" {
  name = "/repo/${var.environment}/output/${var.repo_name}/mq-app-password"
}

# data "aws_ssm_parameter" "vpn_sg" {
#   name = "/repo/${var.environment}/output/prm-deductions-base-infra/vpn-sg"
# }

# State database does not exist yet so the below is temporarily commented out

# data "aws_ssm_parameter" "db-username" {
#   name = "/repo/${var.environment}/user-input/state-db-username"
# }

# data "aws_ssm_parameter" "db-password" {
#   name = "/repo/${var.environment}/user-input/state-db-password"
# }
