variable "db_instance_identifier" {
  description = "The identifier for the database instance."
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage for the database (in GB)."
  type        = number
}

variable "engine" {
  description = "The database engine to use."
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine."
  type        = string
}

variable "instance_class" {
  description = "The instance class for the database."
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The VPC security group IDs to associate with the database instance."
  type        = list(string)
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group to associate with the database instance."
  type        = string
}

variable "username" {
  description = "The master username for the database."
  type        = string
}

variable "password" {
  description = "The master password for the database."
  type        = string
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot of the database instance before deletion."
  type        = bool
}

variable "db_name" {
  type = string
}

variable "kms_key_id" {
  type = string
}
