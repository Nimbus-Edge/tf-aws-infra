variable "hosted_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the Route 53 record"
  type        = string
}

variable "lb_dns_name" {
  description = "The DNS name of the load balancer to which the record points"
  type        = string
}

variable "lb_zone_id" {
  description = "The hosted zone ID of the load balancer"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether to evaluate target health"
  type        = bool
}
