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

output "deductions_private_alb_dns" {
  value = aws_alb.alb.dns_name
}

resource "aws_ssm_parameter" "deductions_private_ecs_cluster_id" {
  name = "/nhs/${var.environment}/deductions_private_ecs_cluster_id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
}

resource "aws_ssm_parameter" "deductions_private_gen_comp_sg_id" {
  name = "/nhs/${var.environment}/deductions_private_gen_comp_sg_id"
  type = "String"
  value = aws_security_group.generic-comp-ecs-task-sg.id
}

resource "aws_ssm_parameter" "deductions_private_gp_to_repo_sg_id" {
  name = "/nhs/${var.environment}/deductions_private_gp_to_repo_sg_id"
  type = "String"
  value = aws_security_group.gp-to-repo-ecs-task-sg.id
}

resource "aws_ssm_parameter" "deductions_private_administration_portal_sg_id" {
  name = "/nhs/${var.environment}/deductions_private_administration_portal_sg_id"
  type = "String"
  value = aws_security_group.administration-portal-ecs-task-sg.id
}

resource "aws_ssm_parameter" "deductions_private_gp2gp_adaptor_sg_id" {
  name = "/nhs/${var.environment}/deductions_private_gp2gp_adaptor_sg_id"
  type = "String"
  value = aws_security_group.gp2gp-adaptor-ecs-task-sg.id
}

resource "aws_ssm_parameter" "deductions_private_private_subnets" {
  name = "/nhs/${var.environment}/deductions_private_private_subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "deductions_private_alb_dns" {
  name = "/nhs/${var.environment}/deductions_private_alb_dns"
  type = "String"
  value = aws_alb.alb.dns_name
}

resource "aws_ssm_parameter" "deductions_private_vpc_id" {
  name = "/nhs/${var.environment}/deductions_private_vpc_id"
  type = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "deductions_private_alb_arn" {
  name = "/nhs/${var.environment}/deductions_private_alb_arn"
  type = "String"
  value = aws_alb.alb.arn
}

resource "aws_ssm_parameter" "deductions_private_alb_httpl_arn" {
  name = "/nhs/${var.environment}/deductions_private_alb_httpl_arn"
  type = "String"
  value = aws_alb_listener.alb-listener.arn
}

resource "aws_ssm_parameter" "deductions_private_alb_httpsl_arn" {
  name = "/nhs/${var.environment}/deductions_private_alb_httpsl_arn"
  type = "String"
  value = aws_alb_listener.alb-listener-https.arn
}

resource "aws_ssm_parameter" "deductions_private_int_alb_httpl_arn" {
  name = "/nhs/${var.environment}/deductions_private_int_alb_httpl_arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener.arn
}

resource "aws_ssm_parameter" "deductions_private_int_alb_httpsl_arn" {
  name = "/nhs/${var.environment}/deductions_private_int_alb_httpsl_arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener-https.arn
}

resource "aws_ssm_parameter" "deductions_private_alb_internal_dns" {
  name = "/nhs/${var.environment}/deductions_private_alb_internal_dns"
  type = "String"
  value = aws_alb.alb-internal.dns_name
}


resource "aws_ssm_parameter" "deductions_private_alb_internal_id" {
  name = "/nhs/${var.environment}/deductions_private_alb_internal_id"
  type = "String"
  value = aws_alb.alb-internal.id
}