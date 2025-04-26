resource "aws_db_instance" "my_db_instance" {
  identifier             = var.db_instance_identifier
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  parameter_group_name   = var.parameter_group_name
  username               = var.username
  password               = var.password
  skip_final_snapshot    = var.skip_final_snapshot
  db_name                = var.db_name
  kms_key_id             = var.kms_key_id
  storage_encrypted      = true
}
