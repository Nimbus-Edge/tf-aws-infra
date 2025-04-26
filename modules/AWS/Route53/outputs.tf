output "route53_app_url" {
  description = "URL for accessing the application"
  value       = "http://${var.domain_name}/"
}
output "route53_zone_id" {
  value       = var.hosted_zone_id
  description = "The ID of the Route 53 hosted zone."
}
