module "container" {
  source                   = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.58.1"
  container_name           = "delius-jitbit"
  container_image          = "374269020027.dkr.ecr.eu-west-2.amazonaws.com/delius-jitbit-ecr-repo:latest"
  container_memory         = "3072"
  container_cpu            = "1536"
  essential                = true
  readonly_root_filesystem = true
  environment = [{
    name  = "AppURL"
    value = "https://delius-jitbit.hmpps-development.modernisation-platform.service.justice.gov.uk/"
  }]
  port_mappings = [{
    container_port = 5000
    host_port      = 5000
  }]
  log_configuration = {
    log_driver = "awslogs"
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
    },
    {
      name      = "S3_User_Key"
      valueFrom = "arn:aws:secretsmanager:eu-west-2:142262177450:secret:delius-jitbit-s3-user-access-key-*"
    },
    {
      name      = "S3_User_Secret"
      valueFrom = "arn:aws:secretsmanager:eu-west-2:142262177450:secret:delius-jitbit-s3-user-secret-key-*"
    }
  ]
}

module "deploy" {
  source                    = "/Users/kyle.hodgetts/repos/github.com/ministryofjustice/terraform-ecs/deploy"
  container_definition_json = module.container.json_map_encoded_list
  ecs_cluster_arn           = "delius-jitbit"
  name                      = "delius-jitbit"
  vpc_id                    = "vpc-01d7a2da8f9f1dfec"

  launch_type  = "EC2"
  network_mode = "awsvpc"

  task_cpu    = "1536"
  task_memory = "3072"

  task_exec_role_arn = []
  task_role_arn      = []

  task_policy_arns = []
  #  capacity_provider_strategies = [
  #    {
  #      capacity_provider = "EC2"
  #      weight = 1
  #      base = 0
  #    }
  #  ]

  ecs_load_balancers = [
    {
      target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:142262177450:targetgroup/delius-jitbit/1e1f2f5f1f2f1f1f"
      container_name   = "delius-jitbit"
      container_port   = 5000
    }
  ]

  force_new_deployment = true

  security_group_ids = []

  subnet_ids = []

  assign_public_ip = true
}