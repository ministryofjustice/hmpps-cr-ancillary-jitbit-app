# locals {
#   app_name       = "delius-jitbit"
#   container_name = "hmpps-${var.environment}-${local.app_name}${var.suffix}"
# }

# module "container" {
#   count = var.active_deployment_colour == null ? 1 : 0

#   source    = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//container?ref=v4.3.0"
#   name      = local.container_name
#   image     = "374269020027.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.app_name}-ecr-repo:${var.image_tag}"
#   essential = true

#   environment = [
#     {
#       name  = "AttachmentsS3Bucket"
#       value = var.s3_bucket_name
#     },
#     {
#       name  = "AttachmentsS3Region"
#       value = "eu-west-2"
#     }
#   ]
#   port_mappings = [{
#     containerPort = 5000
#     hostPort      = 5000
#     protocol      = "tcp"
#   }]

#   mount_points             = []
#   readonly_root_filesystem = false

#   log_configuration = {
#     logDriver = "awslogs"
#     options = {
#       "awslogs-group"         = "${local.app_name}${var.suffix}-ecs"
#       "awslogs-region"        = data.aws_region.current.name
#       "awslogs-stream-prefix" = "jitbit"
#     }
#   }
#   health_check = {
#     command     = ["CMD-SHELL", "wget --spider --server-response http://localhost:5000/User/Login?ReturnURL=%2f 2>&1 | grep -q '200 OK' || exit 1"]
#     interval    = 30
#     retries     = 3
#     startPeriod = 60
#     timeout     = 5
#   }
#   secrets = [
#     {
#       name      = "ConnectionStrings__DBConnectionString"
#       valueFrom = data.aws_secretsmanager_secret.connection_string.arn
#     },
#     {
#       name      = "AttachmentsS3Login"
#       valueFrom = data.aws_secretsmanager_secret.s3_user_access_key.arn
#     },
#     {
#       name      = "AttachmentsS3Password"
#       valueFrom = data.aws_secretsmanager_secret.s3_user_secret_key.arn
#     },
#     {
#       name      = "AppURL"
#       valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.app_name}/environment/app-url"
#     }
#   ]
# }

# module "deploy" {
#   count     = var.active_deployment_colour == null ? 1 : 0

#   source                = "git::https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster//service?ref=v4.3.0"
#   container_definitions = module.container.json_encoded_list
#   cluster_arn           = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/hmpps-${var.environment}-${local.app_name}${var.suffix}"
#   name                  = local.container_name

#   task_cpu    = var.ecs_task_cpu
#   task_memory = var.ecs_task_memory

#   desired_count                      = var.ecs_desired_task_count
#   deployment_maximum_percent         = var.deployment_maximum_percent
#   deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

#   health_check_grace_period_seconds = 30

#   service_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-service"
#   task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task"
#   task_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hmpps-${var.environment}-${local.app_name}-task-exec"

#   enable_execute_command = true
#   service_load_balancers = [
#     {
#       target_group_arn = data.aws_lb_target_group.service.arn
#       container_name   = local.container_name
#       container_port   = 5000
#     }
#   ]

#   security_groups = [var.service_security_group_id]

#   subnets = [
#     data.aws_subnet.private_subnets_a.id,
#     data.aws_subnet.private_subnets_b.id,
#     data.aws_subnet.private_subnets_c.id
#   ]

#   ignore_changes       = false
#   force_new_deployment = false
# }

# resource "aws_ssm_parameter" "ecs_scaling_state" {
#   name  = "/ecs/service/hmpps-${var.environment}-${local.app_name}${var.suffix}/scaling-state"
#   type  = "String"
#   value = "disabled"
#   lifecycle {
#     ignore_changes = [
#       value
#     ]
#   }
# }

# data "aws_ssm_parameter" "ecs_scaling_state" {
#   name = aws_ssm_parameter.ecs_scaling_state.name
# }
