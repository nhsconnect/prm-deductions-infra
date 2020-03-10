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
    username = data.aws_ssm_parameter.mq-admin-username.value
    password = data.aws_ssm_parameter.mq-admin-password.value
    console_access = true
  }

  user {
    username = data.aws_ssm_parameter.mq-app-username.value
    password = data.aws_ssm_parameter.mq-app-password.value
    console_access = false
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_ssm_parameter" "amqp-endpoint-0" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/amqp-endpoint/0"
  description = "AMQP endpoint to MQ broker. Index: 0"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.0.endpoints.1

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "amqp-endpoint-1" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/amqp-endpoint/1"
  description = "AMQP endpoint to MQ broker. Index: 1"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.1.endpoints.1

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "stomp-endpoint-0" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/stomp-endpoint/0"
  description = "STOMP endpoint to MQ broker. Index: 0"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.0.endpoints.2

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "stomp-endpoint-1" {
  name        = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/stomp-endpoint/1"
  description = "STOMP endpoint to MQ broker. Index: 1"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.1.endpoints.2

  tags = {
    Environment = var.environment
  }
}
