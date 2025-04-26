variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the instance"
  type        = string
}

variable "key_name" {
  description = "Key name for the instance"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix for naming"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume"
  type        = number
}

variable "volume_type" {
  description = "Type of volume"
  type        = string
}

variable "user_data_file" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to associate with the instance"
  type        = string
}

variable "bucket_name" {
  type = string
}

variable "region" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "sendgrid_from_email" {
  type = string
}
