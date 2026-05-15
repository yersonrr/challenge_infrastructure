resource "aws_cloudwatch_log_group" "application" {
  name              = "/application/${local.prefix}/api"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-application-logs"
  })
}

resource "aws_cloudwatch_log_group" "operations" {
  name              = "/application/${local.prefix}/operations"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-operations-logs"
  })
}

resource "aws_sns_topic" "alarms" {
  count = var.enable_sns_alarms ? 1 : 0

  name = "${local.prefix}-app-alarms"

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-app-alarms"
  })
}

resource "aws_sns_topic_subscription" "alarm_email" {
  for_each = var.enable_sns_alarms ? toset(var.alarm_email_endpoints) : []

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}
