resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = local.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-github-oidc"
  })
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_oidc_url
}
