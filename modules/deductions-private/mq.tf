resource "aws_mq_broker" "deductor_mq_broker" {
  broker_name                = var.broker_name
  deployment_mode            = var.deployment_mode
  engine_type                = var.engine_type
  engine_version             = var.engine_version
  host_instance_type         = var.host_instance_type
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  publicly_accessible        = "false"
  security_groups            = [aws_security_group.mq_sg.id]
  subnet_ids                 = module.vpc.private_subnets

  logs {
    general = var.general_log
    audit   = var.audit_log
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }

  user {
    username = random_string.mq_admin_user.result
    password = random_string.mq_admin_password.result
    console_access = true
  }
}

resource "aws_secretsmanager_secret" "mq_admin_username" {
  name = "/nhs/dev/mq2/username"
  description = "Amazon MQ Admin Username"
}

resource "aws_secretsmanager_secret_version" "mq_admin_user_value" {
  secret_id     = aws_secretsmanager_secret.mq_admin_username.id
  secret_string = random_string.mq_admin_user.result
}

resource "aws_secretsmanager_secret" "mq_admin_password" {
  name = "/nhs/dev/mq2/password"
  description = "Amazon MQ Admin Password"
}

resource "aws_secretsmanager_secret_version" "mq_admin_password_value" {
  secret_id     = aws_secretsmanager_secret.mq_admin_password.id
  secret_string = random_string.mq_admin_password.result
}

resource "random_string" "mq_admin_user" {
  length  = 8
  special = false
  number  = false
}

resource "random_string" "mq_admin_password" {
  length  = 15
  special = false
  number  = true
}

resource "aws_ssm_parameter" "amqp-endpoint-0" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/amqp-endpoint/0"
  description = "AMQP endpoint to MQ broker. Index: 0"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.0.endpoints.0

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "amqp-endpoint-1" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/amqp-endpoint/1"
  description = "AMQP endpoint to MQ broker. Index: 1"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.1.endpoints.0

  tags = {
    Environment = var.environment
  }
}
