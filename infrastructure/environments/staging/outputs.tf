output "region" {
  description = "Region configured for this workspace."
  value       = var.region
}

output "backend_storage_s3" {
  description = "State bucket name from configuration (must match backend bucket)."
  value       = var.backend_storage_s3
}

output "environment" {
  description = "Environment label from configuration."
  value       = var.environment
}
