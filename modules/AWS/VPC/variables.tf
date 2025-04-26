variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
}

variable "igw_cidr" {
  description = "CIDR block for the Internet Gateway"
  type        = string
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
}

variable "unique_suffix" {
  description = "Unique suffix for naming"
  type        = string
}
