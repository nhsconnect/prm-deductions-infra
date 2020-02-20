resource "aws_ssm_parameter" "deductions_public_ecs_cluster_id" {
  name = "/nhs/${var.environment}/deductions_public_ecs_cluster_id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
}

resource "aws_ssm_parameter" "deductions_public_gp_portal_sg_id" {
  name = "/nhs/${var.environment}/deductions_public_gp_portal_sg_id"
  type = "String"
  value = aws_security_group.gp-portal-ecs-task-sg.id
}

resource "aws_ssm_parameter" "deductions_public_private_subnets" {
  name = "/nhs/${var.environment}/deductions_public_private_subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "deductions_public_alb_dns" {
  name = "/nhs/${var.environment}/deductions_public_alb_dns"
  type = "String"
  value = aws_alb.alb.dns_name
}

resource "aws_ssm_parameter" "deductions_public_alb_httpl_arn" {
  name = "/nhs/${var.environment}/deductions_public_alb_httpl_arn"
  type = "String"
  value = aws_alb_listener.alb-listener.arn
}

resource "aws_ssm_parameter" "deductions_public_vpc_id" {
  name = "/nhs/${var.environment}/deductions_public_vpc_id"
  type = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "deductions_public_alb_arn" {
  name = "/nhs/${var.environment}/deductions_public_alb_arn"
  type = "String"
  value = aws_alb.alb.arn
}
