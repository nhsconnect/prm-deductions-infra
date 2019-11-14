output "deductions_public_ecs_cluster_id" {
  value       = "${module.deductions-public.deductions_public_ecs_cluster_id}"
}

output "deductions_public_ecs_tasks_sg_id" {
  value       = "${module.deductions-public.deductions_public_ecs_tasks_sg_id}"
}

output "deductions_public_private_subnets" {
  value       = "${module.deductions-public.deductions_public_private_subnets}"
}

output "deductions_public_alb_tg_arn" {
  value       = "${module.deductions-public.deductions_public_alb_tg_arn}"
}
