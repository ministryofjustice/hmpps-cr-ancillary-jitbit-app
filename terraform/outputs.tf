output "ecs_cluster_arn" {
  value = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}"
}

output "listener_arn" {
  value = data.aws_lb_listener.lb_listener.arn
}

output "ecs_service_arn_blue" {
  value = length(module.blue_deploy[0]) > 0 ? module.blue_deploy[0].service_arn : null
}

output "ecs_service_arn_green" {
  value = length(module.green_deploy[0]) > 0 ? module.green_deploy[0].service_arn : null
}

output "target_group_arn_blue" {
  value = data.aws_lb_target_group.blue_target_group.arn
}

output "target_group_arn_green" {
  value = data.aws_lb_target_group.green_target_group.arn
}