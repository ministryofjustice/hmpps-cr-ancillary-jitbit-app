variable "lb_name" {
  type        = string
  description = "Name of the loadbalancer"
}


variable "active_deployment_colour" {
  type        = string
  description = "Which deployment color is currently active: 'blue', 'green', or undefined."
  default     = null

  validation {
    condition     = var.active_deployment_colour == null || contains(["blue", "green"], var.active_deployment_colour)
    error_message = "active_deployment_color must be either 'blue', 'green' or not defined"
  }
}

variable "blue_image_tag" {
  type        = string
  description = "Tag of the application image to deploy for 'blue' service"
  default     = ""
}

variable "green_image_tag" {
  type        = string
  description = "Tag of the application image to deploy for 'green' service"
  default     = ""
}