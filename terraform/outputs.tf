output "ecs_cluster_arn" {
  value = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}"
}

output "ecs_service_arn" {
  value = var.sub_env != "sandbox" ? module.deploy[0].service_arn : ""
}
