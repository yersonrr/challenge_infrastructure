data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "apprunner_ecr_access" {
  statement {
    sid    = "ECRGetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
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
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "ECRPullRepository"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [var.ecr_repository_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "apprunner_ecr_access" {
  name = "${var.name}-${var.environment}-apprunner-ecr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "apprunner_ecr_access" {
  name   = "${var.name}-${var.environment}-apprunner-ecr"
  role   = aws_iam_role.apprunner_ecr_access.id
  policy = data.aws_iam_policy_document.apprunner_ecr_access.json
}

data "aws_iam_policy_document" "apprunner_instance" {
  statement {
    sid    = "DynamoDBTables"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = concat(
      var.dynamodb_table_arns,
      [for arn in var.dynamodb_table_arns : "${arn}/index/*"]
    )
  }

  statement {
    sid    = "ReadAppConfigSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.env_secret_manager_arn]
  }
}

resource "aws_iam_role" "apprunner_instance" {
  name = "${var.name}-${var.environment}-apprunner-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "apprunner_instance" {
  name   = "${var.name}-${var.environment}-apprunner-instance"
  role   = aws_iam_role.apprunner_instance.id
  policy = data.aws_iam_policy_document.apprunner_instance.json
}
