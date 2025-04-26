resource "aws_db_parameter_group" "mysql_parameter_group" {
  name        = var.parameter_group_name
  family      = var.parameter_group_family
  description = var.parameter_group_description

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
}
