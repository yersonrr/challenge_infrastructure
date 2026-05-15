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
