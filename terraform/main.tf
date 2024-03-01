locals {
  app_name = "delius-jitbit${var.suffix}"
}

module "container" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.61.1"
  container_name  = local.app_name
  container_image = "374269020027.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.app_name}-ecr-repo:${var.image_tag}"
  essential       = true
  container_definition = {
    initProcessEnabled = true
  }
  environment = [
    {
      name  = "AttachmentsS3Bucket"
      value = var.s3_bucket_name
    },
    {
      name  = "AttachmentsS3Region"
      value = "eu-west-2"
    }
  ]
  port_mappings = [{
    containerPort = 5000
    hostPort      = 5000
    protocol      = "tcp"
  }]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "${local.app_name}-app"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "jitbit"
    }
  }
  healthcheck = {
    command     = ["CMD-SHELL", "wget --spider --server-response http://localhost:5000/User/Login?ReturnURL=%2f 2>&1 | grep -q '200 OK' || exit 1"]
    interval    = 30
    retries     = 3
    startPeriod = 60
    timeout     = 5
  }
  secrets = [
    {
      name      = "ConnectionStrings__DBConnectionString"
      valueFrom = data.aws_secretsmanager_secret.connection_string.arn
    },
    {
      name      = "AttachmentsS3Login"
      valueFrom = data.aws_secretsmanager_secret.s3_user_access_key.arn
    },
    {
      name      = "AttachmentsS3Password"
      valueFrom = data.aws_secretsmanager_secret.s3_user_secret_key.arn
    },
    {
      name      = "AppURL"
      valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.app_name}/environment/app-url"
    }
  ]
}

module "deploy" {
  source                    = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//service?ref=v3.0.0"
  container_definition_json = module.container.json_map_encoded_list
  ecs_cluster_arn           = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}"
  name                      = local.app_name
  vpc_id                    = var.vpc_id

  launch_type  = "FARGATE"
  network_mode = "awsvpc"
  namespace    = "hmpps"

  task_cpu    = var.ecs_task_cpu
  task_memory = var.ecs_task_memory

  desired_count                      = var.ecs_desired_task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  service_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-service"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task"
  task_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task-exec"

  task_exec_policy_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/jitbit-secrets-reader"]
  exec_enabled          = true
  environment           = var.environment
  ecs_load_balancers = [
    {
      target_group_arn = data.aws_lb_target_group.service.arn
      container_name   = local.app_name
      container_port   = 5000
    }
  ]

  security_group_ids = [var.service_security_group_id]

  subnet_ids = [
    data.aws_subnet.private_subnets_a.id,
    data.aws_subnet.private_subnets_b.id,
    data.aws_subnet.private_subnets_c.id
  ]

  ignore_changes_task_definition = false
  redeploy_on_apply              = false
  force_new_deployment           = false
}

data "aws_ecs_service" "this" {
  service_name = "hmpps-${var.environment}-delius-jitbit"
  cluster_arn  = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}"
}

resource "aws_ssm_parameter" "ecs_scaling_state" {
  name  = "/ecs/service/hmpps-${var.environment}-${local.app_name}/scaling-state"
  type  = "String"
  value = "disabled"
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "ecs_scaling_state" {
  name = aws_ssm_parameter.ecs_scaling_state.name
}
