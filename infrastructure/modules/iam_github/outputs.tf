output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

output "github_terraform_oidc_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume via OIDC (then chain to Terraform deployment role)."
  value       = aws_iam_role.github_oidc_terraform.arn
}

output "terraform_deployment_role_arn" {
  description = "IAM role ARN used for Terraform apply (AssumeRole target from GitHub OIDC role)."
  value       = local.terraform_deployment_role_arn
}

output "github_ecr_oidc_role_arn" {
  description = "IAM role ARN for GitHub Actions ECR push via OIDC, or null if disabled."
  value       = var.enable_ecr_role && length(var.ecr_repository_arns) > 0 ? aws_iam_role.github_oidc_ecr[0].arn : null
}
