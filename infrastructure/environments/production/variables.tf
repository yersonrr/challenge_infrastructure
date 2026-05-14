variable "region" {
  description = "AWS region for the provider. Use the same value as backend \"region\" (see backend.hcl.example)."
  type        = string
  default     = "eu-west-1"
}

variable "backend_storage_s3" {
  description = "S3 bucket name for Terraform state. The backend block cannot read variables; set the same name as backend \"bucket\" in backend.hcl."
  type        = string
}

variable "environment" {
  description = "Environment label; matches the path segment under infra_app_url/ in the remote state key."
  type        = string
  default     = "production"
}

variable "role_arn" {
  description = "The ARN of the role to assume"
  type        = string
}
