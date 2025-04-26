variable "vpc_id" {
  description = "The VPC ID where the security groups will be created."
  type        = string
}

variable "ingress_ports" {
  description = "List of ports to allow inbound traffic."
  type        = list(number)
}

variable "protocol" {
  description = "The protocol to use for the security group rules (e.g., tcp)."
  type        = string
}

variable "ingress_cidr" {
  description = "CIDR block for the inbound rules."
  type        = string
}

variable "egress_ports" {
  description = "List of ports to allow outbound traffic."
  type        = list(number)
}

variable "egress_protocol" {
  description = "The protocol to use for the outbound rules (e.g., tcp)."
  type        = string
  default     = "tcp"
}

variable "egress_cidr" {
  description = "CIDR block for the outbound rules."
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix to append to the security group name."
  type        = string
}

variable "source_security_group_ids" {
  description = "The security group ID to allow access from."
  type        = list(string)
}
