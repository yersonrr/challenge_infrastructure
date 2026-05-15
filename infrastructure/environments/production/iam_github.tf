module "iam_github" {
  source = "../../modules/iam_github"

  name        = var.project_name
  environment = var.environment
  region      = var.region

  github_repository = var.github_repository
  github_branches   = var.github_branches
  github_environments = [
    var.environment,
  ]

  terraform_state_bucket_name = var.terraform_state_bucket_name
  ecr_repository_arns         = [module.ecr.repository_arn]
}
