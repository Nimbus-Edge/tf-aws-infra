variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs14.x"
}

variable "role_arn" {
  description = "The ARN of the IAM role the Lambda function assumes"
  type        = string
}

variable "handler" {
  description = "The handler function for the Lambda"
  type        = string
}

variable "sendgrid_from_email" {
  description = "SendGrid 'From' email address"
  type        = string
}

variable "verify_url_base" {
  description = "Base URL for verification"
  type        = string
}

variable "zip_path" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "email_secret_key" {

}
