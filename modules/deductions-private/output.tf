output "deductions_private_ecs_cluster_id" {
  # OBSOLETE, please use SSM
  value = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_private_private_subnets" {
  # OBSOLETE, please use SSM
  value = module.vpc.private_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnets[0]
}

output "dns_server_1" {
  value = cidrhost(var.cidr, 2) # AWS DNS - second IP in the subnet
}

output "private_subnets_route_table_id" {
  # All private nets share a route table
  value = module.vpc.private_route_table_ids[0]
}

output "public_subnets_route_table_id" {
  value = module.vpc.public_route_table_ids[0]
}

# output "deductions_private_alb_dns" {
#   value = aws_alb.alb.dns_name
# }

resource "aws_ssm_parameter" "deductions_private_ecs_cluster_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-ecs-cluster-id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_gen_comp_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-gen-comp-sg-id"
  type = "String"
  value = aws_security_group.generic-comp-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_gp_to_repo_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-gp-to-repo-sg-id"
  type = "String"
  value = aws_security_group.gp-to-repo-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_repo_to_gp_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-repo-to-gp-sg-id"
  type = "String"
  value = aws_security_group.repo-to-gp-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_administration_portal_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-administration-portal-sg-id"
  type = "String"
  value = aws_security_group.administration-portal-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_gp2gp_adaptor_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-gp2gp-adaptor-sg-id"
  type = "String"
  value = aws_security_group.gp2gp-adaptor-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_gp2gp_worker_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-gp2gp-worker-sg-id"
  type = "String"
  value = aws_security_group.gp2gp-worker-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_gp2gp_message_handler_sg_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-gp2gp-message-handler-sg-id"
  type = "String"
  value = aws_security_group.gp2gp-message-handler-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_private_subnets" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-private-subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_vpc_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/private-vpc-id"
  type = "String"
  value = module.vpc.vpc_id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_int_alb_httpl_arn" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-int-alb-httpl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_int_alb_httpsl_arn" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-int-alb-httpsl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener-https.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_alb_internal_dns" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-alb-internal-dns"
  type = "String"
  value = aws_alb.alb-internal.dns_name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}


resource "aws_ssm_parameter" "deductions_private_alb_internal_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-alb-internal-id"
  type = "String"
  value = aws_alb.alb-internal.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
