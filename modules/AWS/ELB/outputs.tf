output "load_balancer_arn" {
  description = "The ARN of the load balancer."
  value       = aws_lb.app_lb.arn
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.app_lb.dns_name
}

output "load_balancer_zone_id" {
  description = "The zone ID of the load balancer."
  value       = aws_lb.app_lb.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group."
  value       = aws_lb_target_group.app_target_group.arn
}

output "target_group_id" {
  description = "The ID of the target group."
  value       = aws_lb_target_group.app_target_group.id
}

output "load_balancer_security_group_id" {
  description = "The security group ID of the load balancer."
  value       = aws_security_group.load_balancer_sg.id
}
