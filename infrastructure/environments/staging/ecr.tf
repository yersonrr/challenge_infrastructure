module "ecr" {
  source = "../../modules/ecr"

  name        = var.project_name
  environment = var.environment

  # ECR push from GitHub uses module.iam_github.github_ecr_oidc_role_arn (inline policy on that role).
  ci_principal_arns = var.ecr_ci_role_arns
}
