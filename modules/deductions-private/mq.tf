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
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "mq-log-publishing-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/amazonmq/*"]

    principals {
      identifiers = ["mq.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "mq-log-publishing-policy" {
  policy_document = data.aws_iam_policy_document.mq-log-publishing-policy.json
  policy_name     = "${var.environment}-mq-log-publishing-policy"
}

# resource "aws_mq_broker" "deductions_mq_broker" {
#   broker_name                = "${var.environment}-deductions-private-mq"
#   deployment_mode            = var.mq_deployment_mode
#   engine_type                = var.engine_type
#   engine_version             = var.engine_version
#   host_instance_type         = var.host_instance_type
#   auto_minor_version_upgrade = var.auto_minor_version_upgrade
#   apply_immediately          = var.apply_immediately
#   publicly_accessible        = "false"
#   security_groups            = [aws_security_group.mq_sg.id]
#   subnet_ids                 = [module.vpc.private_subnets[0]]
#
#   logs {
#     general = var.general_log
#     audit   = var.audit_log
#   }
#
#   maintenance_window_start_time {
#     day_of_week = var.maintenance_day_of_week
#     time_of_day = var.maintenance_time_of_day
#     time_zone   = var.maintenance_time_zone
#   }
#
#   user {
#     username = data.aws_ssm_parameter.mq-admin-username.value
#     password = data.aws_ssm_parameter.mq-admin-password.value
#     console_access = true
#   }
#
#   user {
#     username = data.aws_ssm_parameter.mq-app-username.value
#     password = data.aws_ssm_parameter.mq-app-password.value
#     console_access = false
#   }
#
#   tags = {
#     Terraform = "true"
#     Environment = var.environment
#     Deductions-VPC = var.component_name
#   }
# }

resource "aws_ssm_parameter" "amqp-endpoint-0" {
  name        = "/repo/${var.environment}/prm-deductions-infra/output/amqp-endpoint-0"
  description = "AMQP endpoint to MQ broker. Index: 0"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.0.endpoints.1

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "amqp-endpoint-1" {
  name        = "/repo/${var.environment}/prm-deductions-infra/output/amqp-endpoint-1"
  description = "AMQP endpoint to MQ broker. Index: 1"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.1.endpoints.1

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "stomp-endpoint-0" {
  name        = "/repo/${var.environment}/prm-deductions-infra/output/stomp-endpoint-0"
  description = "STOMP endpoint to MQ broker. Index: 0"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.0.endpoints.2

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "stomp-endpoint-1" {
  name        = "/repo/${var.environment}/prm-deductions-infra/output/stomp-endpoint-1"
  description = "STOMP endpoint to MQ broker. Index: 1"
  type        = "String"
  value       = aws_mq_broker.deductor_mq_broker.instances.1.endpoints.2

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
