output "dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "sns_topic_arn" {
  description = "SNS topic for alarm notifications, or empty if disabled."
  value       = var.enable_sns_alarms ? aws_sns_topic.alarms[0].arn : ""
}

output "application_log_group_name" {
  description = "Name of the CloudWatch log group reserved for API application logs."
  value       = aws_cloudwatch_log_group.application.name
}

output "operations_log_group_name" {
  description = "Name of the CloudWatch log group reserved for operational logs."
  value       = aws_cloudwatch_log_group.operations.name
}
