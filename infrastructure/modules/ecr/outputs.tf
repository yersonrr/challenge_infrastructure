output "repository_url" {
  description = "URL of the ECR repository (use with image tag for App Runner)."
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.app.arn
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.app.name
}

output "ci_policy_arn" {
  description = "IAM policy ARN for CI/CD ECR access, or null if no CI principals were configured."
  value       = length(var.ci_principal_arns) > 0 ? aws_iam_policy.ecr_ci[0].arn : null
}
