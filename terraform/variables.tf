variable "vpc_id" {
  type = string
  description = "VPC ID for the VPC whose private subnets will host the application"
}

variable "environment" {
  type = string
  description = "Environment name"
}
