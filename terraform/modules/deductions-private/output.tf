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

resource "aws_ssm_parameter" "deductions_private_database_subnets" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-database-subnets"
  type = "String"
  value = join(",", module.vpc.database_subnets)
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
