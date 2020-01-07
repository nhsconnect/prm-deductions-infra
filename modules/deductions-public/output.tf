output "deductions_public_ecs_cluster_id" {
  value       = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_public_ecs_tasks_sg_id" {
  value       = aws_security_group.ecs-tasks-sg.id
}

output "deductions_public_private_subnets" {
  value       = aws_subnet.private-subnets.*.id
}

output "deductions_public_alb_dns" {
  value = aws_alb.alb.dns_name
}

output "deductions_public_vpc_id" {
  value       = aws_vpc.main-vpc.id
  description = "VPC Id of the deductions public VPC"
}

output "deductions_public_alb_arn" {
  value       = aws_alb.alb.arn
  description = "urn of the deductions public alb"
}

resource "aws_ssm_parameter" "deductions_public_ecs_cluster_id" {
  name = "/nhs/${var.environment}/deductions_public_ecs_cluster_id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
}

resource "aws_ssm_parameter" "deductions_public_ecs_tasks_sg_id" {
  name = "/nhs/${var.environment}/deductions_public_ecs_tasks_sg_id"
  type = "String"
  value = aws_security_group.ecs-tasks-sg.id
}

resource "aws_ssm_parameter" "deductions_public_private_subnets" {
  name = "/nhs/${var.environment}/deductions_public_private_subnets"
  type = "String"
  value = join(",", aws_subnet.private-subnets.*.id)
}

resource "aws_ssm_parameter" "deductions_public_alb_dns" {
  name = "/nhs/${var.environment}/deductions_public_alb_dns"
  type = "String"
  value = aws_alb.alb.dns_name
}

resource "aws_ssm_parameter" "deductions_public_vpc_id" {
  name = "/nhs/${var.environment}/deductions_public_vpc_id"
  type = "String"
  value = aws_vpc.main-vpc.id
}

resource "aws_ssm_parameter" "deductions_public_alb_arn" {
  name = "/nhs/${var.environment}/deductions_public_alb_arn"
  type = "String"
  value = aws_alb.alb.arn
}
