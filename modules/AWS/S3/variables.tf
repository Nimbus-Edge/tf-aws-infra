variable "bucketname" {
  description = "The name of the S3 bucket"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.bucketname))
    error_message = "The bucket name must only contain lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  type = string
}
