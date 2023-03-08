data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_subnet" "private_subnets_a" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}a"
  }
}

data "aws_subnet" "private_subnets_b" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}b"
  }
}

data "aws_subnet" "private_subnets_c" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}c"
  }
}

data "aws_lb_target_group" "service" {
  name = var.target_group_name
}

data "aws_secretsmanager_secret" "connection_string" {
  name = "${local.app_name}-app-connection-string"
}

data "aws_secretsmanager_secret" "s3_user_access_key" {
  name = "${local.app_name}-s3-user-access-key"
}

data "aws_secretsmanager_secret" "s3_user_secret_key" {
  name = "${local.app_name}-s3-user-secret-key"
}
