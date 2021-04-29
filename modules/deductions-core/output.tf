output "deductions_core_ecs_cluster_id" {
  # OBSOLETE, please use SSM
  value = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_core_private_subnets" {
  # OBSOLETE, please use SSM
  value = module.vpc.private_subnets
}

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
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-core-vpc-id"
  type = "String"
  value = module.vpc.vpc_id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_ecs_cluster_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-core-ecs-cluster-id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_core_private_subnets" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-core-private-subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
