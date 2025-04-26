resource "aws_kms_key" "key" {
  description             = var.key_description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
}
