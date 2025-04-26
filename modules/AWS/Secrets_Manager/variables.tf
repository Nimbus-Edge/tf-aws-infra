variable "name" {
  description = "Name of the secret"
  type        = string
}

variable "secret_data" {
  description = "Secret data to store"
  type        = map(string)
}

variable "kms_key_id" {
  description = "KMS Key to encrypt the secret"
  type        = string
}
