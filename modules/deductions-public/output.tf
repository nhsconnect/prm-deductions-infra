resource "aws_ssm_parameter" "deductions_public_ecs_cluster_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-ecs-cluster-id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_gp_portal_sg_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-gp-portal-sg-id"
  type = "String"
  value = aws_security_group.gp-portal-ecs-task-sg.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_private_subnets" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-private-subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_alb_dns" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-alb-dns"
  type = "String"
  value = aws_alb.alb.dns_name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_alb_httpl_arn" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-alb-httpl-arn"
  type = "String"
  value = aws_alb_listener.alb-listener.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_vpc_id" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-vpc-id"
  type = "String"
  value = module.vpc.vpc_id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_public_alb_arn" {
  name = "/repo/${var.environment}/prm-deductions-infra/output/deductions-public-alb-arn"
  type = "String"
  value = aws_alb.alb.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
