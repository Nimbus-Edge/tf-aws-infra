output "rds_endpoint" {
  value       = aws_db_instance.my_db_instance.endpoint
  description = "The endpoint of the RDS instance"
}

output "rds_username" {
  value       = var.username
  description = "The username for the RDS instance"
}

output "rds_password" {
  value       = var.password
  description = "The password for the RDS instance"
}
