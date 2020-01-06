output "deductions_private_ecs_cluster_id" {
  # OBSOLETE, please use SSM
  value = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_private_ecs_tasks_sg_id" {
  # OBSOLETE, please use SSM
  value = aws_security_group.ecs-tasks-sg.id
}

output "deductions_private_private_subnets" {
  # OBSOLETE, please use SSM
  value = module.vpc.private_subnets
}

output "deductions_private_pds_a_alb_tg_arn" {
  # OBSOLETE, please use SSM
  value = aws_alb_target_group.alb-tg.arn
}

output "deductions_private_gp2gp_a_alb_tg_arn" {
  # OBSOLETE, please use SSM
  value = aws_alb_target_group.gp2gp-alb-tg.arn
}


output "deductions_private_alb_dns" {
  value = aws_alb.alb.dns_name
}

resource "aws_ssm_parameter" "deductions_private_ecs_cluster_id" {
  name = "/nhs/${var.environment}/deductions_private_ecs_cluster_id"
  type = "String"
  value = aws_ecs_cluster.ecs-cluster.id
}

resource "aws_ssm_parameter" "deductions_private_ecs_tasks_sg_id" {
  name = "/nhs/${var.environment}/deductions_private_ecs_tasks_sg_id"
  type = "String"
  value = aws_security_group.ecs-tasks-sg.id
}

resource "aws_ssm_parameter" "deductions_private_private_subnets" {
  name = "/nhs/${var.environment}/deductions_private_private_subnets"
  type = "String"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "deductions_private_gp2gp_a_alb_tg_arn" {
  name = "/nhs/${var.environment}/deductions_private_gp2gp_a_alb_tg_arn"
  type = "String"
  value = aws_alb_target_group.gp2gp-alb-tg.arn
}

resource "aws_ssm_parameter" "deductions_private_pds_a_alb_tg_arn" {
  name = "/nhs/${var.environment}/deductions_private_pds_a_alb_tg_arn"
  type = "String"
  value = aws_alb_target_group.alb-tg.arn
}
