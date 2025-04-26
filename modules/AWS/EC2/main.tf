resource "aws_instance" "ec2_instance" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.public_subnet_id
  vpc_security_group_ids  = [var.security_group_id]
  key_name                = var.key_name
  disable_api_termination = false
  iam_instance_profile    = var.iam_instance_profile

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  user_data = templatefile(var.user_data_file, {
    RDS_ENDPOINT        = var.rds_endpoint
    RDS_USERNAME        = var.rds_username
    RDS_PASSWORD        = var.rds_password
    BUCKET_NAME         = var.bucket_name
    AWS_REGION          = var.region
    SENDGRID_FROM_EMAIL = var.sendgrid_from_email
    SENDGRID_API_KEY    = var.sendgrid_api_key
  })

  tags = {
    Name = "WebappInstance-${var.unique_suffix}"
  }
}
