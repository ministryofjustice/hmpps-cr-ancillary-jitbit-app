output "ecs_cluster_arn" {
  value = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}"
}

output "ecs_service_arn" {
  value = module.deploy.service_arn
}
