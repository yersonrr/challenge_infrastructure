output "web_acl_arn" {
  description = "ARN of the regional WAF web ACL."
  value       = aws_wafv2_web_acl.waf.arn
}

output "web_acl_id" {
  description = "ID of the regional WAF web ACL."
  value       = aws_wafv2_web_acl.waf.id
}

output "web_acl_name" {
  description = "Name of the regional WAF web ACL."
  value       = aws_wafv2_web_acl.waf.name
}

output "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs, or null if logging is disabled."
  value       = var.enable_waf_logging ? aws_cloudwatch_log_group.waf[0].name : null
}

output "security_auditor_policy_arn" {
  description = "IAM policy ARN for security auditor read-only access, or null if no roles were configured."
  value       = length(var.security_auditor_role_arns) > 0 ? aws_iam_policy.security_auditor[0].arn : null
}
