data "aws_iam_policy_document" "ecr_ci" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_policy" "ecr_ci" {
  count = length(var.ci_principal_arns) > 0 ? 1 : 0

  name        = "${var.name}-${var.environment}-ecr-ci"
  description = "Allow CI/CD to push and pull images from ${aws_ecr_repository.app.name}"
  policy      = data.aws_iam_policy_document.ecr_ci.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecr_ci" {
  for_each = length(var.ci_principal_arns) > 0 ? toset(var.ci_principal_arns) : toset([])

  role       = element(split(":role/", each.value), 1)
  policy_arn = aws_iam_policy.ecr_ci[0].arn
}
