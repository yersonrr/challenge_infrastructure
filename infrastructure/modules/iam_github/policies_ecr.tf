data "aws_iam_policy_document" "github_ecr" {
  count = var.enable_ecr_role && length(var.ecr_repository_arns) > 0 ? 1 : 0

  statement {
    sid    = "ECRGetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid    = "ECRPushPullRepository"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = var.ecr_repository_arns

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  dynamic "statement" {
    for_each = length(var.apprunner_service_arns) > 0 ? [1] : []

    content {
      sid    = "AppRunnerDeploy"
      effect = "Allow"
      actions = [
        "apprunner:DescribeService",
        "apprunner:ListOperations",
        "apprunner:StartDeployment",
      ]
      resources = var.apprunner_service_arns
    }
  }
}
