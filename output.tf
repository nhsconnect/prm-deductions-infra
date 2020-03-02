# Deductions Private Outputs
output "deductions_private_ecs_cluster_id" {
  value       = module.deductions-private.deductions_private_ecs_cluster_id
}

output "deductions_private_ecs_tasks_sg_id" {
  value       = module.deductions-private.deductions_private_ecs_tasks_sg_id
}

output "deductions_private_private_subnets" {
  value       = module.deductions-private.deductions_private_private_subnets
}

output "deductions_private_alb_dns" {
  value       = module.deductions-private.deductions_private_alb_dns
}

output "dns_server_1" {
  value = module.deductions-private.dns_server_1
}

# Deductions Core Outputs
output "deductions_core_ecs_cluster_id" {
  value       = module.deductions-core.deductions_core_ecs_cluster_id
}

output "deductions_core_ecs_tasks_sg_id" {
  value       = module.deductions-core.deductions_core_ecs_tasks_sg_id
}

output "deductions_core_private_subnets" {
  value       = module.deductions-core.deductions_core_private_subnets
}

output "deductions_core_database_subnets" {
  value       = module.deductions-core.deductions_core_database_subnets
}

output "deductions_core_ehr_repo_alb_tg_arn" {
  value       = module.deductions-core.deductions_core_ehr_repo_alb_tg_arn
}

output "deductions_core_alb_dns" {
  value       = module.deductions-core.deductions_core_alb_dns
}
