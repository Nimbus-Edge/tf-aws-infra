variable "region" {
  description = "Region"
}
variable "profile" {
  description = "AWS profile"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
}

variable "igw_cidr" {
  description = "CIDR block for routing via the Internet Gateway"
  type        = string
}

variable "ingress_cidr" {
  description = "CIDR block for the inbound rules."
  type        = string
}

variable "egress_cidr" {
  description = "CIDR block for the outbound rules."
  type        = string
}

variable "egress_ports_for_db" {
  description = "List of ports to allow outbound traffic."
  type        = list(number)
}

variable "egress_ports" {
  description = "List of ports to allow outbound traffic."
  type        = list(number)
}

variable "parameter_group_family" {
  type = string
}

variable "max_connections" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "db_instance_identifier" {
  type = string
}
variable "allocated_storage" {
  type = number
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "skip_final_snapshot" {
  type = bool
}

variable "ami_id" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "app_sg_ingress" {
  type = list(number)
}

variable "db_sg_ingress" {
  type = list(number)
}

variable "bucketname" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "sendgrid_from_email" {
  type = string
}

variable "load_balancer_name" {
  type = string
}

variable "load_balancer_ingress_cidr" {
  type = list(string)
}

variable "load_balancer_target_port" {
  type = number
}

variable "load_balancer_target_protocol" {
  type = string
}

variable "load_balancer_health_check_path" {
  type = string
}

variable "load_balancer_health_check_protocol" {
  type = string
}

variable "load_balancer_health_check_interval" {
  type = number
}

variable "load_balancer_health_check_timeout" {
  type = number
}

variable "load_balancer_health_check_healthy_threshold" {
  type = number
}

variable "load_balancer_health_check_unhealthy_threshold" {
  type = number
}

variable "auto_scaler_max_size" {
  type = number
}

variable "auto_scaler_min_size" {
  type = number
}

variable "auto_scaler_desired_capacity" {
  type = number
}

variable "auto_scaler_instance_name" {
  type = string
}

variable "scale_up_policy_name" {
  type = string
}

variable "scale_up_scaling_adjustment" {
  type = number
}

variable "scale_up_adjustment_type" {
  type = string
}

variable "scale_up_cooldown" {
  type = number
}

variable "scale_down_policy_name" {
  type = string
}

variable "scale_down_scaling_adjustment" {
  type = number
}

variable "scale_down_adjustment_type" {
  type = string
}

variable "scale_down_cooldown" {
  type = number
}

variable "scale_up_alarm_name" {
  type = string
}

variable "scale_up_comparison_operator" {
  type = string
}

variable "scale_up_metric_name" {
  type = string
}

variable "scale_up_namespace" {
  type = string
}

variable "scale_up_period" {
  type = number
}

variable "scale_up_statistic" {
  type = string
}

variable "scale_up_threshold" {
  type = number
}

variable "scale_down_alarm_name" {
  type = string
}

variable "scale_down_comparison_operator" {
  type = string
}

variable "scale_down_metric_name" {
  type = string
}

variable "scale_down_namespace" {
  type = string
}

variable "scale_down_period" {
  type = number
}

variable "scale_down_statistic" {
  type = string
}

variable "scale_down_threshold" {
  type = number
}

variable "route53_evaluate_target_health" {
  type = bool
}

variable "username" {
  type = string
}

variable "sns_topic_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}
