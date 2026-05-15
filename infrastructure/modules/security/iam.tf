data "aws_iam_policy_document" "security_auditor" {
  statement {
    sid    = "WAFReadOnly"
    effect = "Allow"
    actions = [
      "wafv2:CheckCapacity",
      "wafv2:DescribeManagedRuleGroup",
      "wafv2:DescribeRuleGroup",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:ListResourcesForWebACL",
      "wafv2:ListRuleGroups",
      "wafv2:ListTagsForResource",
      "wafv2:ListWebACLs"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "WAFLogsReadOnly"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "logs:GetLogEvents"
    ]
    resources = var.enable_waf_logging ? ["${aws_cloudwatch_log_group.waf[0].arn}:*"] : ["*"]
  }

  statement {
    sid    = "CloudWatchMetricsReadOnly"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "security_auditor" {
  count = length(var.security_auditor_role_arns) > 0 ? 1 : 0

  name        = "${var.name}-${var.environment}-security-auditor"
  description = "Read-only access to WAF and related security telemetry for ${var.environment}."
  policy      = data.aws_iam_policy_document.security_auditor.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "security_auditor" {
  for_each = length(var.security_auditor_role_arns) > 0 ? toset(var.security_auditor_role_arns) : toset([])

  role       = element(split(":role/", each.value), 1)
  policy_arn = aws_iam_policy.security_auditor[0].arn
}
