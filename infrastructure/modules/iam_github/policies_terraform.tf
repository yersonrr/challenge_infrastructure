data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "TerraformStateList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.terraform_state_key_prefix}*"]
    }
  }

  statement {
    sid    = "TerraformStateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${local.state_bucket_arn}/${var.terraform_state_key_prefix}*",
    ]
  }
}

data "aws_iam_policy_document" "terraform_deploy" {
  source_policy_documents = [data.aws_iam_policy_document.terraform_state.json]

  statement {
    sid    = "ProjectDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:UpdateContinuousBackups",
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${local.account_id}:table/${local.resource_prefix}-*",
    ]
  }

  statement {
    sid    = "ProjectECR"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:ListTagsForResource",
      "ecr:PutImageTagMutability",
      "ecr:GetRepositoryPolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${local.account_id}:repository/${local.resource_prefix}-*",
    ]
  }

  statement {
    sid    = "ProjectAppRunner"
    effect = "Allow"
    actions = [
      "apprunner:CreateAutoScalingConfiguration",
      "apprunner:DeleteAutoScalingConfiguration",
      "apprunner:DescribeAutoScalingConfiguration",
      "apprunner:CreateVpcConnector",
      "apprunner:DeleteVpcConnector",
      "apprunner:DescribeVpcConnector",
      "apprunner:CreateService",
      "apprunner:DeleteService",
      "apprunner:DescribeService",
      "apprunner:UpdateService",
      "apprunner:ListServices",
      "apprunner:TagResource",
      "apprunner:UntagResource",
      "apprunner:ListTagsForResource",
      "apprunner:AssociateWebAcl",
      "apprunner:DisassociateWebAcl",
    ]
    resources = [
      "arn:aws:apprunner:${var.region}:${local.account_id}:service/${local.resource_prefix}-*/*",
      "arn:aws:apprunner:${var.region}:${local.account_id}:autoscalingconfiguration/${local.resource_prefix}-*/*",
      "arn:aws:apprunner:${var.region}:${local.account_id}:vpcconnector/${local.resource_prefix}-*/*",
    ]
  }

  statement {
    sid    = "ProjectWAF"
    effect = "Allow"
    actions = [
      "wafv2:CreateWebACL",
      "wafv2:DeleteWebACL",
      "wafv2:UpdateWebACL",
      "wafv2:GetWebACL",
      "wafv2:ListTagsForResource",
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:PutLoggingConfiguration",
      "wafv2:DeleteLoggingConfiguration",
    ]
    resources = [
      "arn:aws:wafv2:${var.region}:${local.account_id}:regional/webacl/${local.resource_prefix}-*/*",
    ]
  }

  statement {
    sid    = "ProjectEC2Network"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:DescribeAddresses",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:DescribeNatGateways",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:ReplaceRoute",
      "ec2:DescribeRouteTables",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:DescribeVpcEndpoints",
      "ec2:ModifyVpcEndpoint",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid    = "ProjectIAM"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${local.resource_prefix}-*",
      "arn:aws:iam::${local.account_id}:policy/${local.resource_prefix}-*",
      "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "apprunner.amazonaws.com",
        "build.apprunner.amazonaws.com",
        "tasks.apprunner.amazonaws.com",
        "ec2.amazonaws.com",
        "vpc-flow-logs.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "ProjectLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
      "logs:ListTagsForResource",
      "logs:PutResourcePolicy",
      "logs:DeleteResourcePolicy",
      "logs:DescribeResourcePolicies",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/waf/${var.name}-${var.environment}*",
    ]
  }

  statement {
    sid    = "ApplicationAutoscaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:DescribeScalingPolicies",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid    = "ReadOnlyDiscovery"
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeNetworkInterfaces",
      "iam:GetRole",
      "iam:GetPolicy",
      "iam:GetOpenIDConnectProvider",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}
