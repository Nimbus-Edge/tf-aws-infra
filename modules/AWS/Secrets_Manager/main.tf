resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  kms_key_id  = var.kms_key_id
  description = "Secret for ${var.name}"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secret_data)
}
