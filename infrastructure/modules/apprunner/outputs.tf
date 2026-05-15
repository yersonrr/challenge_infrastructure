output "service_url" {
  description = "Public URL of the App Runner service."
  value       = "https://${aws_apprunner_service.api.service_url}"
}

output "service_arn" {
  description = "ARN of the App Runner service."
  value       = aws_apprunner_service.api.arn
}

output "service_id" {
  description = "ID of the App Runner service."
  value       = aws_apprunner_service.api.id
}

output "service_name" {
  description = "App Runner service name (CloudWatch dimension ServiceName)."
  value       = aws_apprunner_service.api.service_name
}

output "vpc_connector_arn" {
  description = "ARN of the VPC connector, or null if disabled."
  value       = var.enable_vpc_connector ? aws_apprunner_vpc_connector.main[0].arn : null
}

output "instance_role_arn" {
  description = "IAM role ARN attached to App Runner instances (DynamoDB + Secrets Manager)."
  value       = aws_iam_role.apprunner_instance.arn
}

output "env_secret_manager_arn" {
  description = "ARN of the Secrets Manager secret used for application configuration."
  value       = var.env_secret_manager_arn
}
