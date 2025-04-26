output "vpc_id" {
  value = aws_vpc.vpc1.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "rds_subnet_group_id" {
  description = "The ID of the RDS subnet group."
  value       = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_subnet_group_name" {
  description = "The name of the RDS subnet group."
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "rds_subnet_ids" {
  description = "The subnet IDs in the RDS subnet group."
  value       = aws_db_subnet_group.rds_subnet_group.subnet_ids
}
