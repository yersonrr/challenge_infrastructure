output "region" {
  description = "Region configured for this workspace."
  value       = var.region
}


output "environment" {
  description = "Environment label from configuration."
  value       = var.environment
}

output "vpc_id" {
  description = "VPC ID from the network module."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs from the network module."
  value       = module.network.private_subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs from the network module."
  value       = module.network.security_group_ids
}

output "urls_table_name" {
  description = "DynamoDB table name for short URLs."
  value       = module.db.urls_table_name
}

output "users_table_name" {
  description = "DynamoDB table name for user authentication."
  value       = module.db.users_table_name
}

output "dynamodb_table_names" {
  description = "DynamoDB table names from the db module."
  value       = module.db.table_names
}

output "ecr_repository_url" {
  description = "ECR repository URL for container images."
  value       = module.ecr.repository_url
}

output "apprunner_service_url" {
  description = "Public HTTPS URL of the App Runner service."
  value       = module.apprunner.service_url
}

output "env_secret_manager_arn" {
  description = "Secrets Manager ARN used by App Runner for application configuration."
  value       = module.apprunner.env_secret_manager_arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL protecting App Runner."
  value       = module.security.web_acl_arn
}
