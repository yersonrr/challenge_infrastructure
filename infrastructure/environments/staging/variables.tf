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

variable "github_repository" {
  description = "GitHub repository allowed to use OIDC (org/repo)."
  type        = string
}

variable "github_branches" {
  description = "Git branches allowed to assume GitHub OIDC roles."
  type        = list(string)
  default     = ["main", "staging"]
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket for Terraform remote state (must match backend bucket)."
  type        = string
  default     = "challenge-terraform-states"
}

variable "ecr_ci_role_arns" {
  description = "Extra IAM role ARNs for ECR push (optional; GitHub OIDC ECR role is configured in iam_github)."
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

variable "waf_rate_limit" {
  description = "WAF rate limit: max requests per IP per 5-minute window."
  type        = number
  default     = 100
}

variable "waf_enable_ip_reputation" {
  description = "Enable AWS managed IP reputation WAF rules."
  type        = bool
  default     = true
}

variable "waf_enable_bot_control" {
  description = "Enable AWS WAF Bot Control (additional cost)."
  type        = bool
  default     = false
}

variable "security_auditor_role_arns" {
  description = "IAM role ARNs granted read-only WAF and security log access."
  type        = list(string)
  default     = []
}
