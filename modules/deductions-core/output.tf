output "deductions_core_ecs_cluster_id" {
  # OBSOLETE, please use SSM
  value = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_core_ecs_tasks_sg_id" {
  # OBSOLETE, please use SSM
  value = aws_security_group.ecs-tasks-sg.id
}

output "deductions_core_private_subnets" {
  # OBSOLETE, please use SSM
  value = module.vpc.private_subnets
}

output "deductions_core_database_subnets" {
  value = module.vpc.database_subnets
}

# output "deductions_core_ehr_repo_alb_tg_arn" {
#   # OBSOLETE, please use SSM
#   value = aws_alb_target_group.ehr-repo-alb-tg.arn
# }

# output "deductions_core_alb_dns" {
#   value = aws_alb.alb.dns_name
# }

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets_route_table_id" {
  # All private nets share a route table
  value = module.vpc.private_route_table_ids[0]
}

output "public_subnets_route_table_id" {
  # All private nets share a route table
  value = module.vpc.public_route_table_ids[0]
}

resource "aws_ssm_parameter" "deductions_core_vpc_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-vpc-id"
  type = "String"
  value = module.vpc.vpc_id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_ecs_cluster_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-ecs-cluster-id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_ecs_tasks_sg_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-ecs-tasks-sg-id"
  type = "String"
  value = aws_security_group.ecs-tasks-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_private_subnets" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-private-subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_internal_alb_dns" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-internal-alb-dns"
  type = "String"
  value = aws_alb.alb-internal.dns_name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_int_alb_httpl_arn" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-int-alb-httpl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener-http.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_int_alb_httpsl_arn" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-core-int-alb-httpsl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener-https.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
