# blue
module "container_blue" {
  count     = var.blue_green == "blue" || var.ecs_switch ? 1 : 0
  source    = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//container?ref=v4.3.0"
  name      = "${local.container_name}-blue"
  image     = "374269020027.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.app_name}-ecr-repo:${var.image_tag_blue}"
  essential = true

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

  mount_points             = []
  readonly_root_filesystem = false

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "${local.app_name}${var.suffix}-ecs-blue"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "jitbit"
    }
  }
  health_check = {
    command     = ["CMD-SHELL", "wget --spider --server-response http://localhost:5000/User/Login?ReturnURL=%2f 2>&1 | grep -q '200 OK' || exit 1"]
    interval    = 30
    retries     = 3
    startPeriod = 60
    timeout     = 5
  }
  secrets = [
    {
      name      = "blue_green"
      valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/blue_green"
    }
    # {
    #   name      = "ConnectionStrings__DBConnectionString"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AttachmentsS3Login"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AttachmentsS3Password"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AppURL"
    #   valueFrom = "empty" # while testing
    # }
  ]
}

module "deploy_blue" {
  count                 = var.blue_green == "blue" || var.ecs_switch ? 1 : 0
  source                = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//service?ref=v4.3.0"
  container_definitions = module.container_blue[0].json_encoded_list
  cluster_arn           = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}-blue"
  name                  = "${local.container_name}-blue"

  task_cpu    = var.ecs_task_cpu
  task_memory = var.ecs_task_memory

  desired_count                      = var.ecs_desired_task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  health_check_grace_period_seconds = 30

  service_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-service"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task"
  task_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task-exec"

  enable_execute_command = true
  service_load_balancers = [
    {
      target_group_arn = data.aws_lb_target_group.blue.arn
      container_name   = "${local.container_name}-blue"
      container_port   = 5000
    }
  ]

  security_groups = [var.service_security_group_id]

  subnets = [
    data.aws_subnet.private_subnets_a.id,
    data.aws_subnet.private_subnets_b.id,
    data.aws_subnet.private_subnets_c.id
  ]

  ignore_changes       = false
  force_new_deployment = false
}

# green

module "container_green" {
  count     = var.blue_green == "green" || var.ecs_switch ? 1 : 0
  source    = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//container?ref=v4.3.0"
  name      = "${local.container_name}-green"
  image     = "374269020027.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.app_name}-ecr-repo:${var.image_tag_green}"
  essential = true

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

  mount_points             = []
  readonly_root_filesystem = false

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "${local.app_name}${var.suffix}-ecs-green"
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-stream-prefix" = "jitbit"
    }
  }
  health_check = {
    command     = ["CMD-SHELL", "wget --spider --server-response http://localhost:5000/User/Login?ReturnURL=%2f 2>&1 | grep -q '200 OK' || exit 1"]
    interval    = 30
    retries     = 3
    startPeriod = 60
    timeout     = 5
  }
  secrets = [
    {
      name      = "blue_green"
      valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/blue_green"
    }
    # {
    #   name      = "ConnectionStrings__DBConnectionString"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AttachmentsS3Login"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AttachmentsS3Password"
    #   valueFrom = "empty" # while testing
    # },
    # {
    #   name      = "AppURL"
    #   valueFrom = "empty" # while testing
    # }
  ]
}

module "deploy_green" {
  count                 = var.blue_green == "green" || var.ecs_switch ? 1 : 0
  source                = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//service?ref=v4.3.0"
  container_definitions = module.container_green[0].json_encoded_list
  cluster_arn           = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}-green"
  name                  = "${local.container_name}-green"

  task_cpu    = var.ecs_task_cpu
  task_memory = var.ecs_task_memory

  desired_count                      = var.ecs_desired_task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  health_check_grace_period_seconds = 30

  service_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-service"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task"
  task_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task-exec"

  enable_execute_command = true
  service_load_balancers = [
    {
      target_group_arn = data.aws_lb_target_group.green.arn
      container_name   = "${local.container_name}-green"
      container_port   = 5000
    }
  ]

  security_groups = [var.service_security_group_id]

  subnets = [
    data.aws_subnet.private_subnets_a.id,
    data.aws_subnet.private_subnets_b.id,
    data.aws_subnet.private_subnets_c.id
  ]

  ignore_changes       = false
  force_new_deployment = false
}
