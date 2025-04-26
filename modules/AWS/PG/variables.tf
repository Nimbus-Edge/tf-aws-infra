variable "parameter_group_name" {
  description = "Name of the RDS MySQL parameter group."
  type        = string
}

variable "parameter_group_family" {
  description = "The family of the parameter group (e.g., mysql8.0)."
  type        = string
}

variable "parameter_group_description" {
  description = "Description for the RDS MySQL parameter group."
}

variable "max_connections" {
  description = "The maximum number of connections allowed."
  type        = string
}
