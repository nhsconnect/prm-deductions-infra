# Deductions Public Outputs
output "deductions_public_ecs_cluster_id" {
  value       = module.deductions-public.deductions_public_ecs_cluster_id
}

output "deductions_public_ecs_tasks_sg_id" {
  value       = module.deductions-public.deductions_public_ecs_tasks_sg_id
}

output "deductions_public_private_subnets" {
  value       = module.deductions-public.deductions_public_private_subnets
}

output "deductions_public_vpc_id" {
  value       = module.deductions-public.deductions_public_vpc_id
}

output "deductions_public_alb_dns" {
  value       = module.deductions-public.deductions_public_alb_dns
}

output "deductions_public_alb_arn" {
  value       = module.deductions-public.deductions_public_alb_arn
}

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

output "deductions_private_pds_a_alb_tg_arn" {
  value       = module.deductions-private.deductions_private_pds_a_alb_tg_arn
}

output "deductions_private_gp2gp_a_alb_tg_arn" {
  value       = module.deductions-private.deductions_private_gp2gp_a_alb_tg_arn
}


output "deductions_private_alb_dns" {
  value       = module.deductions-private.deductions_private_alb_dns
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
