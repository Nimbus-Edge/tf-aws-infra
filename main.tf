resource "random_string" "unique_suffix" {
  length  = 8
  special = false
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "%@/"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source               = "./modules/AWS/VPC"
  vpc_cidr             = var.vpc_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  igw_cidr             = var.igw_cidr
  unique_suffix        = random_string.unique_suffix.result
}

module "app_security_group" {
  source                    = "./modules/AWS/SG"
  vpc_id                    = module.vpc.vpc_id
  ingress_ports             = var.app_sg_ingress
  protocol                  = "tcp"
  ingress_cidr              = var.ingress_cidr
  egress_ports              = var.egress_ports
  egress_protocol           = "tcp"
  egress_cidr               = var.egress_cidr
  unique_suffix             = random_string.unique_suffix.result
  source_security_group_ids = [module.load_balancer.load_balancer_security_group_id]
}

module "db_security_group" {
  source                    = "./modules/AWS/SG"
  vpc_id                    = module.vpc.vpc_id
  ingress_ports             = var.db_sg_ingress
  protocol                  = "tcp"
  ingress_cidr              = module.app_security_group.security_group_id
  egress_ports              = var.egress_ports_for_db
  unique_suffix             = random_string.unique_suffix.result
  egress_cidr               = var.egress_cidr
  source_security_group_ids = [module.app_security_group.security_group_id, module.lambda_security_group.security_group_id]
}

module "lambda_security_group" {
  source                    = "./modules/AWS/SG"
  vpc_id                    = module.vpc.vpc_id
  ingress_ports             = []
  protocol                  = "tcp"
  ingress_cidr              = null
  egress_ports              = [80, 443]
  egress_cidr               = var.egress_cidr
  unique_suffix             = random_string.unique_suffix.result
  source_security_group_ids = null
}

module "kms_rds" {
  source                  = "./modules/AWS/KMS"
  key_description         = "KMS key for encrypting RDS instances"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

module "kms_s3" {
  source                  = "./modules/AWS/KMS"
  key_description         = "KMS key for encrypting S3 buckets"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

module "kms_ec2" {
  source                  = "./modules/AWS/KMS"
  key_description         = "KMS key for encrypting EC2 instances"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

module "rds_secret" {
  source = "./modules/AWS/Secrets_Manager"
  name   = "rds-database-password_${random_string.unique_suffix.result}-1"
  secret_data = {
    username = var.db_username
    password = random_password.rds_password.result
  }
  kms_key_id = module.kms_rds.kms_key_id
}

module "email_service_secret" {
  source = "./modules/AWS/Secrets_Manager"
  name   = "email-service-credentialsName_${random_string.unique_suffix.result}-1"
  secret_data = {
    api_key = var.sendgrid_api_key
  }
  kms_key_id = module.kms_rds.kms_key_id
}


module "parameter_group" {
  source                      = "./modules/AWS/PG"
  parameter_group_name        = var.parameter_group_name
  parameter_group_family      = var.parameter_group_family
  parameter_group_description = var.parameter_group_name
  max_connections             = var.max_connections
}

module "rds_instance" {
  source                 = "./modules/AWS/RDS"
  db_instance_identifier = var.db_instance_identifier
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  db_subnet_group_name   = module.vpc.rds_subnet_group_name
  vpc_security_group_ids = [module.db_security_group.security_group_id]
  parameter_group_name   = module.parameter_group.mysql_parameter_group
  username               = var.db_username
  db_name                = var.db_name
  skip_final_snapshot    = true
  depends_on             = [module.db_security_group, module.parameter_group]
  kms_key_id             = module.kms_rds.kms_key_id
  password               = random_password.rds_password.result
}

module "s3bucket" {
  source     = "./modules/AWS/S3"
  bucketname = var.bucketname
  kms_key_id = module.kms_s3.kms_key_id
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "lambda-cloudwatch-logs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_secrets_manager_policy" {
  name        = "LambdaSecretsManagerFullAccess"
  description = "Custom policy to allow full access to Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_secrets_manager_policy_attachment" {
  name       = "lambda-secrets-manager-policy-attachment"
  policy_arn = aws_iam_policy.lambda_secrets_manager_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_kms_policy_attachment" {
  name       = "lambda-kms-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  roles      = [aws_iam_role.lambda_role.name]
}


resource "aws_iam_role_policy" "lambda_rds_policy" {
  name = "lambda-rds-access-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect",
          "rds:ExecuteStatement",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_network_policy" {
  name = "lambda-network-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_access" {
  name        = "SecretsManagerAccessPolicy"
  description = "Allows EC2 to access all secrets in Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*"
      }
    ]
  })
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_kms_policy" {
  name = "EC2KMSPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:*"
        ]
        Resource = "*"
      }
    ]
  })
}


# IAM Policy for S3 Actions
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow S3 actions (add, modify, remove)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${module.s3bucket.bucket_name}",
          "arn:aws:s3:::${module.s3bucket.bucket_name}/*"
        ]
      }
    ]
  })
}

# IAM Policy for Full CloudWatch Logs, CloudWatch, and CloudWatch V2 Access
resource "aws_iam_policy" "cloudwatch_full_access_policy" {
  name        = "CloudWatchFullAccessPolicy"
  description = "Policy to allow full access to CloudWatch, CloudWatch Logs, and CloudWatch V2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*",
          "cloudwatch:*",
          "cloudwatch:GetMetricData",
          "cloudwatch:PutMetricData",
          "cloudwatch:ListMetrics"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "load_balancer_full_access_policy" {
  name        = "LoadBalancerFullAccessPolicy"
  description = "Policy to allow full access to Elastic Load Balancing (ELB)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:*",

        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "autoscaling_full_access_policy" {
  name        = "AutoScalingFullAccessPolicy"
  description = "Policy to allow full access to Auto Scaling"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroup",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "route53_full_access_policy" {
  name        = "Route53FullAccessPolicy"
  description = "Policy to allow full access to Route 53"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:CreateHostedZone",
          "route53:DeleteHostedZone",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:GetChange"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "SNSTopicPublishPolicy"
  description = "Policy to allow publishing to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}


# Attach Policies to the IAM Role
resource "aws_iam_policy_attachment" "attach_kms_policy" {
  name       = "KMSPolicyAttachment"
  roles      = [aws_iam_role.ec2_role.name, aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
}
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "S3PolicyAttachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "CloudWatchPolicyAttachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.cloudwatch_full_access_policy.arn
}

resource "aws_iam_policy_attachment" "attach_secrets_policy" {
  name       = "SecretsPolicyAttachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.secrets_manager_access.arn
}

resource "aws_iam_policy_attachment" "autoscaling_policy_attachment" {
  name       = "AutoScalingPolicyAttachment"
  users      = [var.username]
  policy_arn = aws_iam_policy.autoscaling_full_access_policy.arn
}

resource "aws_iam_policy_attachment" "route53_policy_attachment" {
  name       = "Route53PolicyAttachment"
  users      = [var.username]
  policy_arn = aws_iam_policy.route53_full_access_policy.arn
}

resource "aws_iam_policy_attachment" "load_balancer_policy_attachment" {
  name       = "LoadBalancerPolicyAttachment"
  users      = [var.username]
  policy_arn = aws_iam_policy.load_balancer_full_access_policy.arn
}


resource "aws_iam_policy_attachment" "sns_publish_policy_attachment" {
  name       = "SNSTopicPublishPolicyAttachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}


# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

module "sns_topic" {
  source     = "./modules/AWS/SNS"
  topic_name = var.sns_topic_name
}

module "launch_template" {
  source               = "./modules/AWS/Launch_Template"
  unique_suffix        = random_string.unique_suffix.result
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  key_name             = var.key_name
  volume_type          = var.volume_type
  volume_size          = var.volume_size
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  security_group_id    = module.app_security_group.security_group_id
  user_data_file       = "${path.module}/ec2.sh"
  rds_endpoint         = module.rds_instance.rds_endpoint
  rds_username         = module.rds_instance.rds_username
  rds_password         = module.rds_instance.rds_password
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  depends_on           = [module.app_security_group, module.rds_instance]
  bucket_name          = module.s3bucket.bucket_name
  region               = var.region
  sendgrid_api_key     = var.sendgrid_api_key
  sendgrid_from_email  = var.sendgrid_from_email
  subnet_id            = element(module.vpc.public_subnet_ids, 0)
  security_group_ids   = [module.app_security_group.security_group_id]
  topic_name           = module.sns_topic.sns_topic_arn
  db_key               = module.rds_secret.secret_name
  sendgrid_key         = module.email_service_secret.secret_name
}

module "lambda_function" {
  source              = "./modules/AWS/Lambda"
  function_name       = "my-lambda-function"
  runtime             = "nodejs20.x"
  role_arn            = aws_iam_role.lambda_role.arn
  handler             = "index.handler"
  sendgrid_from_email = var.sendgrid_from_email
  verify_url_base     = var.domain_name
  zip_path            = "/Users/deepakviswanadha/NEU_GIT/Fall 24/Cloud/serverless"
  security_group_ids  = [module.lambda_security_group.security_group_id]
  subnet_ids          = module.vpc.private_subnet_ids
  email_secret_key    = module.email_service_secret.secret_name
}

resource "aws_lambda_permission" "allow_sns_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = module.lambda_function.lambda_function_arn
  source_arn    = module.sns_topic.sns_topic_arn
}

# Subscribe Lambda to SNS
resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  topic_arn = module.sns_topic.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda_function.lambda_function_arn
}

module "load_balancer" {
  source                           = "./modules/AWS/ELB"
  name                             = var.load_balancer_name
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = module.vpc.public_subnet_ids
  ingress_cidr                     = var.load_balancer_ingress_cidr
  target_port                      = var.load_balancer_target_port
  target_protocol                  = var.load_balancer_target_protocol
  health_check_path                = var.load_balancer_health_check_path
  health_check_protocol            = var.load_balancer_health_check_protocol
  health_check_interval            = var.load_balancer_health_check_interval
  health_check_timeout             = var.load_balancer_health_check_timeout
  health_check_healthy_threshold   = var.load_balancer_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.load_balancer_health_check_unhealthy_threshold
  acm_certificate_arn              = var.certificate_arn
}

module "auto_scaler" {
  source              = "./modules/AWS/ASG"
  max_size            = var.auto_scaler_max_size
  min_size            = var.auto_scaler_min_size
  desired_capacity    = var.auto_scaler_desired_capacity
  instance_name       = var.auto_scaler_instance_name
  launch_template_id  = module.launch_template.launch_template_id
  vpc_zone_identifier = module.vpc.public_subnet_ids
  target_group_arns   = [module.load_balancer.target_group_arn]
  depends_on          = [module.launch_template]
}


# Scale-up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = var.scale_up_policy_name
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = module.auto_scaler.autoscaling_group_name
  depends_on             = [module.launch_template]
}


# Scale-down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = var.scale_down_policy_name
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = module.auto_scaler.autoscaling_group_name
  depends_on             = [module.launch_template]
}


# Scale-up CloudWatch Alarm
module "scale_up_alarm" {
  source                 = "./modules/AWS/CloudWatch_Alarm"
  name                   = var.scale_up_alarm_name
  comparison_operator    = var.scale_up_comparison_operator
  metric_name            = var.scale_up_metric_name
  namespace              = var.scale_up_namespace
  period                 = var.scale_up_period
  statistic              = var.scale_up_statistic
  threshold              = var.scale_up_threshold
  alarm_actions          = [aws_autoscaling_policy.scale_up.arn]
  autoscaling_group_name = module.auto_scaler.autoscaling_group_name
  depends_on             = [module.launch_template]
}


# Scale-down CloudWatch Alarm
module "scale_down_alarm" {
  source                 = "./modules/AWS/CloudWatch_Alarm"
  name                   = var.scale_down_alarm_name
  comparison_operator    = var.scale_down_comparison_operator
  metric_name            = var.scale_down_metric_name
  namespace              = var.scale_down_namespace
  period                 = var.scale_down_period
  statistic              = var.scale_down_statistic
  threshold              = var.scale_down_threshold
  alarm_actions          = [aws_autoscaling_policy.scale_down.arn]
  autoscaling_group_name = module.auto_scaler.autoscaling_group_name
  depends_on             = [module.launch_template]
}

# Route 53
module "route53" {
  source                 = "./modules/AWS/Route53"
  hosted_zone_id         = var.hosted_zone_id
  domain_name            = var.domain_name
  lb_dns_name            = module.load_balancer.load_balancer_dns_name
  lb_zone_id             = module.load_balancer.load_balancer_zone_id
  evaluate_target_health = var.route53_evaluate_target_health
}

#Certificate

# module "ssl-certificate" {
#   source          = "./modules/AWS/Certificate"
#   domain_name     = var.domain_name
#   alternate_names = []
#   hosted_zone_id  = module.route53.route53_zone_id
#   depends_on      = [module.route53]
# }
