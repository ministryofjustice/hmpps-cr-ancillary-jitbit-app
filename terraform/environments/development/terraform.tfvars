vpc_id                             = "vpc-01d7a2da8f9f1dfec"
environment                        = "development"
target_group_name                  = "delius-jitbit"
service_security_group_id          = "sg-0a530e9283a2e64e5"
s3_bucket_name                     = "delius-jitbit-development-20230621100033732800000001"
ecs_task_cpu                       = 2048
ecs_task_memory                    = 4096
ecs_desired_task_count             = 1
deployment_minimum_healthy_percent = 0
deployment_maximum_percent         = 100
jitbit_version                     = "10.19"
