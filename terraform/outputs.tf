output "ecs_cluster_arn" {
  value = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}"
}

output "ecs_service_arn" {
  value = !var.blue_green_active ? module.deploy[0].service_arn : ""
}

# output "listener_arn" {
#   value = data.aws_lb_listener.lb_listener.arn
# }

output "ecs_service_arn_blue" {
  value = var.blue_green_active && var.blue_image_tag != "" ? module.blue_deploy[0].service_arn : ""
}

output "ecs_service_arn_green" {
  value = var.blue_green_active && var.green_image_tag != "" ? module.green_deploy[0].service_arn : ""
}

output "target_group_arn_blue" {
  value = var.blue_green_active ? data.aws_lb_target_group.blue_target_group[0].arn : ""
}

output "target_group_arn_green" {
  value = var.blue_green_active ? data.aws_lb_target_group.green_target_group[0].arn : ""
}