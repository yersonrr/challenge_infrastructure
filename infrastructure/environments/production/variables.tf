variable "project_name" {
  description = "Short name used as a prefix for network and other shared resources."
  type        = string
  default     = "challenge"
}

variable "region" {
  description = "AWS region for the provider. Use the same value as backend region."
  type        = string
  default     = "eu-west-1"
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

variable "ecr_ci_role_arns" {
  description = "IAM role ARNs for CI/CD to push images to ECR."
  type        = list(string)
  default     = []
}

variable "app_image_tag" {
  description = "ECR image tag deployed to App Runner."
  type        = string
  default     = "latest"
}

variable "env_secret_manager_arn" {
  description = "ARN of the existing Secrets Manager secret (JSON) for app configuration. Create and restrict access outside Terraform."
  type        = string
}

variable "apprunner_min_size" {
  description = "Minimum App Runner instances."
  type        = number
  default     = 1
}

variable "apprunner_max_size" {
  description = "Maximum App Runner instances."
  type        = number
  default     = 5
}
