output "deductions_core_ecs_cluster_id" {
  value = aws_ecs_cluster.ecs-cluster.id
}

output "deductions_core_ecs_tasks_sg_id" {
  value = aws_security_group.ecs-tasks-sg.id
}

output "deductions_core_private_subnets" {
  value = module.vpc.private_subnets
}

output "deductions_core_database_subnets" {
  value = module.vpc.database_subnets
}

output "deductions_core_ehr_repo_alb_tg_arn" {
  value = aws_alb_target_group.ehr-repo-alb-tg.arn
}

output "deductions_core_alb_dns" {
  value = aws_alb.alb.dns_name
}