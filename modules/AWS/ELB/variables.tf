variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be created."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the load balancer."
  type        = list(string)
}

variable "ingress_cidr" {
  description = "CIDR blocks to allow traffic to the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_port" {
  description = "The port on which the target group will listen."
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "The protocol used by the target group."
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "The destination for the health check request."
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "The protocol used for the health check."
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "The time between health checks."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "The amount of time to wait for a health check response."
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "The number of successful health checks required before considering an unhealthy target healthy."
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "The number of failed health checks required before considering a target unhealthy."
  type        = number
  default     = 3
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}
