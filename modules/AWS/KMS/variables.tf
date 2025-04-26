variable "key_description" {
  description = "Description of the KMS key"
  type        = string
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
}

variable "deletion_window_in_days" {
  description = "Days before the key is deleted after scheduling"
  type        = number
}
