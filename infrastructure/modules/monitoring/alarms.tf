
# 5xx absolute spike (rapid increase in server errors)
resource "aws_cloudwatch_metric_alarm" "http_5xx_spike" {
  alarm_name          = "${local.prefix}-apprunner-5xx-spike"
  alarm_description   = "High count of 5xx responses from App Runner in one period."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxStatusResponses"
  namespace           = "AWS/AppRunner"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.alarm_5xx_sum_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.app_runner_service_name
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}


# 5xx error rate (% of requests)
resource "aws_cloudwatch_metric_alarm" "http_5xx_error_rate" {
  alarm_name          = "${local.prefix}-apprunner-5xx-rate"
  alarm_description   = "5xx responses as a percentage of total HTTP requests."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_5xx_error_rate_percent_threshold
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      metric_name = "5xxStatusResponses"
      namespace   = "AWS/AppRunner"
      period      = var.alarm_period_seconds
      stat        = "Sum"

      dimensions = {
        ServiceName = var.app_runner_service_name
      }
    }
  }

  metric_query {
    id          = "m2"
    return_data = false

    metric {
      metric_name = "Requests"
      namespace   = "AWS/AppRunner"
      period      = var.alarm_period_seconds
      stat        = "Sum"

      dimensions = {
        ServiceName = var.app_runner_service_name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "IF(m2 == 0, 0, (m1 / m2) * 100)"
    label       = "5xx error rate %"
    return_data = true
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}

# High latency (p99)
resource "aws_cloudwatch_metric_alarm" "request_latency_p99" {
  alarm_name          = "${local.prefix}-apprunner-latency-p99"
  alarm_description   = "p99 request processing latency is elevated."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_latency_p99_ms_threshold
  treat_missing_data  = "notBreaching"

  metric_name        = "RequestLatency"
  namespace          = "AWS/AppRunner"
  period             = var.alarm_period_seconds
  extended_statistic = "p99"

  dimensions = {
    ServiceName = var.app_runner_service_name
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}

# Load / scaling: high concurrency (service-level)
resource "aws_cloudwatch_metric_alarm" "high_concurrency" {
  alarm_name          = "${local.prefix}-apprunner-high-concurrency"
  alarm_description   = "Concurrent requests approaching estimated capacity; scaling or saturation risk."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "Concurrency"
  namespace           = "AWS/AppRunner"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = local.concurrency_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.app_runner_service_name
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}

# Scaling: all instances active at configured maximum
resource "aws_cloudwatch_metric_alarm" "active_instances_at_max" {
  alarm_name          = "${local.prefix}-apprunner-instances-at-max"
  alarm_description   = "Active instances at autoscaling maximum; may indicate need to raise max_size or concurrency."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ActiveInstances"
  namespace           = "AWS/AppRunner"
  period              = var.alarm_period_seconds
  statistic           = "Maximum"
  threshold           = var.app_runner_max_instances
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.app_runner_service_name
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}

# CPU stress (service aggregate) — supports “anomaly” investigation
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.prefix}-apprunner-cpu-high"
  alarm_description   = "Aggregated CPU utilization high across the App Runner service."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AppRunner"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = 85
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = var.app_runner_service_name
  }

  alarm_actions             = local.alarm_actions
  ok_actions                = local.alarm_actions
  insufficient_data_actions = []

  tags = local.common_tags
}
