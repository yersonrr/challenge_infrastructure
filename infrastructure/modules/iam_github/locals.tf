data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  resource_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "iam_github"
      Environment = var.environment
    },
    var.tags
  )

  github_oidc_url      = "https://token.actions.githubusercontent.com"
  github_oidc_provider = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"

  github_oidc_subjects = concat(
    [for branch in var.github_branches : "repo:${var.github_repository}:ref:refs/heads/${branch}"],
    [for env in var.github_environments : "repo:${var.github_repository}:environment:${env}"]
  )

  terraform_deployment_role_arn = var.create_terraform_deployment_role ? aws_iam_role.terraform_deployment[0].arn : var.terraform_deployment_role_arn

  state_bucket_arn = "arn:aws:s3:::${var.terraform_state_bucket_name}"
}
