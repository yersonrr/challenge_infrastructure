resource "aws_iam_role" "github_oidc_terraform" {
  name               = "${local.resource_prefix}-github-terraform-oidc"
  description        = "GitHub Actions OIDC role that assumes the Terraform deployment role."
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-github-terraform-oidc"
  })
}

data "aws_iam_policy_document" "github_oidc_assume_terraform" {
  statement {
    sid    = "AssumeTerraformDeploymentRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [local.terraform_deployment_role_arn]
  }
}

resource "aws_iam_role_policy" "github_oidc_assume_terraform" {
  name   = "${local.resource_prefix}-assume-terraform"
  role   = aws_iam_role.github_oidc_terraform.id
  policy = data.aws_iam_policy_document.github_oidc_assume_terraform.json
}

resource "aws_iam_role" "terraform_deployment" {
  count = var.create_terraform_deployment_role ? 1 : 0

  name                 = "${local.resource_prefix}-terraform-deploy"
  description          = "Terraform apply role for GitHub Actions (${var.environment})."
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubOIDCRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.github_oidc_terraform.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-terraform-deploy"
  })
}

resource "aws_iam_role_policy" "terraform_deployment" {
  count = var.create_terraform_deployment_role ? 1 : 0

  name   = "${local.resource_prefix}-terraform-deploy"
  role   = aws_iam_role.terraform_deployment[0].id
  policy = data.aws_iam_policy_document.terraform_deploy.json
}

resource "aws_iam_role" "github_oidc_ecr" {
  count = var.enable_ecr_role && length(var.ecr_repository_arns) > 0 ? 1 : 0

  name               = "${local.resource_prefix}-github-ecr-oidc"
  description        = "GitHub Actions OIDC role for ECR image push."
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-github-ecr-oidc"
  })
}

resource "aws_iam_role_policy" "github_oidc_ecr" {
  count = var.enable_ecr_role && length(var.ecr_repository_arns) > 0 ? 1 : 0

  name   = "${local.resource_prefix}-github-ecr"
  role   = aws_iam_role.github_oidc_ecr[0].id
  policy = data.aws_iam_policy_document.github_ecr[0].json
}
