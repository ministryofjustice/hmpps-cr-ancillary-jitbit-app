variable "vpc_id" {
  type        = string
  description = "VPC ID for the VPC whose private subnets will host the application"
}

variable "environment" {
  type        = string
  description = "Environment name"
  validation {
    condition     = contains(["development", "test", "preproduction", "production"], var.environment)
    error_message = "Valid values for environment are (development, test, preproduction, production)"
  }
}

variable "target_group_name" {
  type        = string
  description = "Name of the target group to register the service with"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Version of the application image to deploy"
}

variable "s3_bucket_name" {
  type        = string
  default     = "latest"
  description = "s3 bucket name for app"
}

variable "service_security_group_id" {
  type        = string
  description = "Security group to associate with the service"
  default     = ""
}

variable "ecs_task_cpu" {
  type        = number
  description = "The number of CPU units used by the task. If using FARGATE launch type task_cpu must match supported memory values [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size]"
}

variable "ecs_task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the task. If using Fargate launch type task_memory must match supported cpu values [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size]"
}
