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

output "deductions_public_alb_tg_arn" {
  value       = module.deductions-public.deductions_public_alb_tg_arn
}

output "deductions_public_alb_dns" {
  value       = module.deductions-public.deductions_public_alb_dns
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

output "deductions_private_alb_dns" {
  value       = module.deductions-private.deductions_private_alb_dns
}
