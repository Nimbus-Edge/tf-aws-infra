variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "alternate_names" {
  description = "List of alternate domain names for the certificate"
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID for the domain in Route 53"
  type        = string
}
