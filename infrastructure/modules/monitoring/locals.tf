locals {
  prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "monitoring"
      Environment = var.environment
    },
    var.tags,
  )

  # Default high concurrency: ~80% of max instances * per-instance concurrency
  concurrency_threshold = coalesce(
    var.alarm_high_concurrency_threshold,
    floor(var.app_runner_max_instances * var.app_runner_max_concurrency_per_instance * 0.8),
  )

  alarm_actions = var.enable_sns_alarms ? [aws_sns_topic.alarms[0].arn] : []
}
