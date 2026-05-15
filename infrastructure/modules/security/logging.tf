resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_waf_logging ? 1 : 0

  name              = "/aws/waf/${var.name}-${var.environment}"
  retention_in_days = var.waf_log_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-waf-logs"
  })
}

data "aws_iam_policy_document" "waf_log_delivery" {
  count = var.enable_waf_logging ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    resources = ["${aws_cloudwatch_log_group.waf[0].arn}:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  count = var.enable_waf_logging ? 1 : 0

  policy_name     = "${var.name}-${var.environment}-waf-logs"
  policy_document = data.aws_iam_policy_document.waf_log_delivery[0].json
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_waf_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.waf.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]

  depends_on = [aws_cloudwatch_log_resource_policy.waf]
}
