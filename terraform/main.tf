module "container" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.58.1"
  container_name           = "delius-jitbit"
  container_image          = "374269020027.dkr.ecr.eu-west-2.amazonaws.com/delius-jitbit-ecr-repo:latest"
  container_memory         = "3072"
  container_cpu            = "1024"
  essential                = true
  readonly_root_filesystem = false
  environment = [{
    name  = "AppURL"
    value = "https://delius-jitbit.hmpps-development.modernisation-platform.service.justice.gov.uk/"
  }]
  port_mappings = [{
    containerPort = 5000
    hostPort      = 5000
    protocol      = "tcp"
  }]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "delius-jitbit-ecs"
      "awslogs-region"        = "eu-west-2"
      "awslogs-stream-prefix" = "jitbit"
    }
  }
  secrets = [
    {
      name      = "ConnectionStrings__DBConnectionString"
      valueFrom = "arn:aws:secretsmanager:eu-west-2:142262177450:secret:delius-jitbit-app-connection-string-xMnuvx"
    }
  ]
}

module "deploy" {
  source                    = "git::https://github.com/ministryofjustice/terraform-ecs//service?ref=2c33fa204d94c615d4d5f92469cd34ae85ad50e3"
  container_definition_json = module.container.json_map_encoded_list
  ecs_cluster_arn           = "arn:aws:ecs:eu-west-2:142262177450:cluster/hmpps-development-delius-jitbit-new"
  name                      = "delius-jitbit"
  vpc_id                    = "vpc-01d7a2da8f9f1dfec"

  launch_type  = "FARGATE"
  network_mode = "awsvpc"

  task_cpu    = "1024"
  task_memory = "3072"

  task_exec_role_arn = "arn:aws:iam::142262177450:role/delius-jitbit-ecs-task-execution-role"
  # task_role_arn      = []

  environment = terraform.workspace

  # task_policy_arns = []
  #  capacity_provider_strategies = [
  #    {
  #      capacity_provider = "EC2"
  #      weight = 1
  #      base = 0
  #    }
  #  ]

  ecs_load_balancers = [
    {
      target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:142262177450:targetgroup/delius-jitbit-tg-development-new/9dce0b9265ed25e0"
      container_name   = "delius-jitbit"
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

  # assign_public_ip = true
}
