locals {
  service_dim = var.app_runner_service_name

  base_metric_properties = {
    view    = "timeSeries"
    stacked = false
    region  = var.region
    period  = var.alarm_period_seconds
  }

  traffic_metrics = [
    ["AWS/AppRunner", "Requests", "ServiceName", local.service_dim],
    [".", "2xxStatusResponses", ".", "."],
    [".", "4xxStatusResponses", ".", "."],
    [".", "5xxStatusResponses", ".", "."],
  ]

  latency_metrics = [
    ["AWS/AppRunner", "RequestLatency", "ServiceName", local.service_dim, { stat = "p50" }],
    ["...", { stat = "p99" }],
  ]

  scaling_metrics = [
    ["AWS/AppRunner", "Concurrency", "ServiceName", local.service_dim],
    [".", "ActiveInstances", ".", "."],
    [".", "CPUUtilization", ".", "."],
    [".", "MemoryUtilization", ".", "."],
  ]

  alarm_widget = {
    type   = "alarm"
    x      = 12
    y      = 6
    width  = 12
    height = 6
    properties = {
      title = "CloudWatch alarms"
      alarms = [
        aws_cloudwatch_metric_alarm.http_5xx_spike.arn,
        aws_cloudwatch_metric_alarm.http_5xx_error_rate.arn,
        aws_cloudwatch_metric_alarm.request_latency_p99.arn,
        aws_cloudwatch_metric_alarm.high_concurrency.arn,
        aws_cloudwatch_metric_alarm.active_instances_at_max.arn,
        aws_cloudwatch_metric_alarm.cpu_high.arn,
      ]
    }
  }

  waf_log_widget = var.waf_log_group_name == null ? [] : [
    {
      type   = "log"
      x      = 0
      y      = 15
      width  = 24
      height = 6
      properties = {
        query   = "SOURCE '${var.waf_log_group_name}' | fields @timestamp, action, httpRequest.clientIp, terminatingRuleId\n| sort @timestamp desc\n| limit 50"
        region  = var.region
        title   = "WAF log sample"
        stacked = false
      }
    },
  ]

  metric_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = merge(local.base_metric_properties, {
        title   = "HTTP requests & status buckets"
        metrics = local.traffic_metrics
        stat    = "Sum"
      })
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = merge(local.base_metric_properties, {
        title   = "Request latency (p50 / p99)"
        metrics = local.latency_metrics
      })
    },
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = merge(local.base_metric_properties, {
        title   = "Concurrency, instances, CPU, memory"
        metrics = local.scaling_metrics
      })
    },
    local.alarm_widget,
    {
      type   = "text"
      x      = 0
      y      = 12
      width  = 24
      height = 3
      properties = {
        markdown = <<-EOT
          ## URL shortener — ${var.environment} (${var.name})

          Application log groups (retention configured): `/application/${local.prefix}/api`, `/application/${local.prefix}/operations`.

          Point App Runner observability / log destinations at these groups when you enable application logs in the console or API.
          EOT
      }
    },
  ]

  dashboard_widgets = concat(local.metric_widgets, local.waf_log_widget)
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.prefix}-url-shortener"

  dashboard_body = jsonencode({
    widgets = local.dashboard_widgets
  })
}
