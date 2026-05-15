variable "name" {
  description = "Project name prefix (aligns with other modules)."
  type        = string
}

variable "environment" {
  description = "Environment label (staging, production)."
  type        = string
}

variable "region" {
  description = "AWS region (dashboard widgets and provider context)."
  type        = string
}

variable "app_runner_service_name" {
  description = "App Runner service name for CloudWatch metrics (dimension ServiceName)."
  type        = string
}

variable "app_runner_min_instances" {
  description = "Minimum App Runner instances (used for scaling context)."
  type        = number
  default     = 1
}

variable "app_runner_max_instances" {
  description = "Maximum App Runner instances; used for near-capacity alarms."
  type        = number
  default     = 5
}

variable "app_runner_max_concurrency_per_instance" {
  description = "max_concurrency from App Runner autoscaling; used to estimate capacity for concurrency alarms."
  type        = number
  default     = 100
}

variable "log_retention_days" {
  description = "Retention for application/operations log groups created by this module."
  type        = number
  default     = 14
}

variable "enable_sns_alarms" {
  description = "Create SNS topic and attach alarm actions."
  type        = bool
  default     = true
}

variable "alarm_email_endpoints" {
  description = "Email addresses to subscribe to the alarm topic (each must confirm in AWS)."
  type        = list(string)
  default     = []
}

variable "alarm_5xx_sum_threshold" {
  description = "Absolute 5xx count per evaluation period (Sum over period seconds) that triggers spike alarm."
  type        = number
  default     = 25
}

variable "alarm_5xx_error_rate_percent_threshold" {
  description = "5xx as percentage of total Requests (metric math); triggers when above this for evaluation_periods."
  type        = number
  default     = 5
}

variable "alarm_latency_p99_ms_threshold" {
  description = "p99 RequestLatency in milliseconds."
  type        = number
  default     = 3000
}

variable "alarm_high_concurrency_threshold" {
  description = "Approximate concurrent requests that indicate heavy load (default ~80% of max theoretical)."
  type        = number
  default     = null
}

variable "alarm_evaluation_periods" {
  description = "Number of periods for single-metric alarms (except where overridden)."
  type        = number
  default     = 2
}

variable "alarm_period_seconds" {
  description = "Period in seconds for App Runner metric alarms."
  type        = number
  default     = 300
}

variable "waf_log_group_name" {
  description = "Optional WAF CloudWatch log group name to link in the dashboard (from security module)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default     = {}
}
