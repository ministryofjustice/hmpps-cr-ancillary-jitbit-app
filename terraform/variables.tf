variable "vpc_id" {
  type        = string
  description = "VPC ID for the VPC whose private subnets will host the application"
}

variable "environment" {
  type        = string
  description = "Environment name"
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

variable "service_security_group_id" {
  type        = string
  description = "Security group to associate with the service"
  default     = ""
}

variable "alb_security_group_id" {
  type        = string
  description = <<-EOT
    Security group of the ALB serving the application.
    This is used to create a rule to allow your service to accept traffic from the load balancer"
    EOT
}
