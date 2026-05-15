variable "project_name" {
  description = "Short name used as a prefix for network and other shared resources."
  type        = string
  default     = "challenge"
}

variable "region" {
  description = "AWS region for the provider. Use the same value as backend \"region\" (see backend.hcl.example)."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment label; matches the path segment under infra_app_url/ in the remote state key."
  type        = string
  default     = "staging"
}

variable "role_arn" {
  description = "The ARN of the role to assume"
  type        = string
}
