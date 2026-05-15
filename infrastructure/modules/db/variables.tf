variable "name" {
  description = "Name prefix for DynamoDB tables."
  type        = string
}

variable "environment" {
  description = "Environment used in resource names and tags."
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode. PAY_PER_REQUEST (on-demand) is recommended for the challenge."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "read_capacity" {
  description = "Read capacity units when billing_mode is PROVISIONED."
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units when billing_mode is PROVISIONED."
  type        = number
  default     = 5
}

variable "enable_autoscaling" {
  description = "Enable application autoscaling for PROVISIONED tables. Ignored when billing_mode is PAY_PER_REQUEST."
  type        = bool
  default     = false
}

variable "autoscaling_read_min" {
  description = "Minimum read capacity for autoscaling."
  type        = number
  default     = 1
}

variable "autoscaling_read_max" {
  description = "Maximum read capacity for autoscaling."
  type        = number
  default     = 100
}

variable "autoscaling_write_min" {
  description = "Minimum write capacity for autoscaling."
  type        = number
  default     = 1
}

variable "autoscaling_write_max" {
  description = "Maximum write capacity for autoscaling."
  type        = number
  default     = 100
}

variable "urls_ttl_enabled" {
  description = "Enable TTL on the URLs table using the expiresAt attribute."
  type        = bool
  default     = true
}

variable "enable_urls_owner_gsi" {
  description = "Create ownerId-createdAt GSI to list short links by owner."
  type        = bool
  default     = true
}

variable "enable_users_email_gsi" {
  description = "Create email GSI for user lookup during authentication."
  type        = bool
  default     = true
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery on both tables."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection on both tables."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
