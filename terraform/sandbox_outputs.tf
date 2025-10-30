output "listener_arn" {
  value = data.aws_lb_listener.sandbox_lb_listener.arn
}

output "ecs_service_arn_blue" {
  value = var.sub_env == "sandbox" && var.blue_image_tag != "" ? module.blue_deploy[0].service_arn : ""
}

output "ecs_service_arn_green" {
  value = var.sub_env == "sandbox" && var.green_image_tag != "" ? module.green_deploy[0].service_arn : ""
}

output "target_group_arn_blue" {
  value = data.aws_lb_target_group.sandbox_blue_target_group.arn
}

output "target_group_arn_green" {
  value = data.aws_lb_target_group.sandbox_green_target_group.arn
}