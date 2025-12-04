locals {
  blue_target_group_name  = "${var.target_group_name}-blue"
  green_target_group_name = "${var.target_group_name}-green"
}

data "aws_lb" "sandbox_lb" {
  name = var.lb_name
}

data "aws_lb_listener" "sandbox_lb_listener" {
  load_balancer_arn = data.aws_lb.sandbox_lb.arn
  port              = 443
}

data "aws_lb_target_group" "sandbox_blue_target_group" {
  count = var.sub_env == "sandbox" ? 1 : 0
  name  = local.blue_target_group_name
}

data "aws_lb_target_group" "sandbox_green_target_group" {
  count = var.sub_env == "sandbox" ? 1 : 0
  name  = local.green_target_group_name
}
