variable "name" {
  description = "Name prefix for security resources."
  type        = string
}

variable "environment" {
  description = "Environment used in resource names and tags."
  type        = string
}

variable "apprunner_service_arn" {
  description = "ARN of the App Runner service to associate with the WAF web ACL."
  type        = string
}

variable "rate_limit" {
  description = "Maximum requests allowed per IP within the rate-limit evaluation window (AWS WAF uses a 5-minute window for IP aggregation)."
  type        = number
  default     = 100
}

variable "enable_ip_reputation" {
  description = "Enable the AWS managed IP reputation rule group."
  type        = bool
  default     = true
}

variable "enable_bot_control" {
  description = "Enable AWS WAF Bot Control (additional cost; use for bot protection)."
  type        = bool
  default     = false
}

variable "bot_control_inspection_level" {
  description = "Bot Control inspection level when enable_bot_control is true (COMMON or TARGETED)."
  type        = string
  default     = "COMMON"

  validation {
    condition     = contains(["COMMON", "TARGETED"], var.bot_control_inspection_level)
    error_message = "bot_control_inspection_level must be COMMON or TARGETED."
  }
}

variable "enable_waf_logging" {
  description = "Send WAF logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "waf_log_retention_days" {
  description = "CloudWatch Logs retention for WAF logs."
  type        = number
  default     = 30
}

variable "security_auditor_role_arns" {
  description = "IAM role ARNs that receive read-only WAF/CloudWatch access for security review."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
