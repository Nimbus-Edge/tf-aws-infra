output "secret_arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN of the created secret"
}

output "secret_name" {
  value = aws_secretsmanager_secret.this.name
}
