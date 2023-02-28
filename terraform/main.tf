locals {
  app_name = "delius-jitbit"
}

data "aws_secretsmanager_secret" "connection_string" {
  name = "${local.app_name}-app-connection-string"
}

module "container" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.58.1"
  container_name           = local.app_name
  container_image          = "374269020027.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.app_name}-ecr-repo:latest"
  container_memory         = "3072"
  container_cpu            = "1024"
  essential                = true
  readonly_root_filesystem = false
  environment = [{
    name  = "AppURL"
    value = "https://${local.app_name}.hmpps-development.modernisation-platform.service.justice.gov.uk/"
  }]
  port_mappings = [{
    containerPort = 5000
    hostPort      = 5000
    protocol      = "tcp"
  }]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "${local.app_name}-ecs"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "jitbit"
    }
  }
  secrets = [
    {
      name      = "ConnectionStrings__DBConnectionString"
      valueFrom = data.aws_secretsmanager_secret.connection_string.arn
    }
  ]
}

module "deploy" {
  source                    = "git::https://github.com/ministryofjustice/terraform-ecs//service?ref=2c33fa204d94c615d4d5f92469cd34ae85ad50e3"
  container_definition_json = module.container.json_map_encoded_list
  ecs_cluster_arn           = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}-new"
  name                      = local.app_name
  vpc_id                    = var.vpc_id

  launch_type  = "FARGATE"
  network_mode = "awsvpc"

  task_cpu    = "1024"
  task_memory = "3072"

  task_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.app_name}-ecs-task-execution-role"

  environment = var.environment
  ecs_load_balancers = [
    {
      target_group_arn = "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/delius-jitbit-tg-development-new/9dce0b9265ed25e0"
      container_name   = local.app_name
      container_port   = 5000
    }
  ]

  security_group_ids    = ["sg-07a92e5d14a64479b"]
  alb_security_group_id = "sg-0f741aa47c861ed1a"

  subnet_ids = [
    data.aws_subnet.private_subnets_a.id,
    data.aws_subnet.private_subnets_b.id,
    data.aws_subnet.private_subnets_c.id
  ]

  ignore_changes_task_definition = false
}
