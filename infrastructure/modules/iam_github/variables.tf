variable "name" {
  description = "Project name prefix for IAM role and policy names."
  type        = string
}

variable "environment" {
  description = "Environment label (staging, production)."
  type        = string
}

variable "region" {
  description = "AWS region where CI/CD deploys resources."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in org/repo format allowed to assume roles (e.g. challenge_infrastructure)."
  type        = string
}

variable "github_branches" {
  description = "Git branches allowed in the OIDC sub claim (refs/heads/<branch>)."
  type        = list(string)
  default     = ["main"]
}

variable "github_environments" {
  description = "GitHub Environments allowed in the OIDC sub claim (environment:<name>)."
  type        = list(string)
  default     = []
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider in this account. Set false if it already exists."
  type        = bool
  default     = true
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket name used for Terraform remote state."
  type        = string
}

variable "terraform_state_key_prefix" {
  description = "Key prefix for Terraform state objects in the state bucket."
  type        = string
  default     = "infra_app_url/"
}

variable "create_terraform_deployment_role" {
  description = "Create a dedicated IAM role for Terraform apply with least-privilege project policies."
  type        = bool
  default     = true
}

variable "terraform_deployment_role_arn" {
  description = "Existing IAM role ARN for Terraform to assume after GitHub OIDC auth. Required when create_terraform_deployment_role is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_terraform_deployment_role || var.terraform_deployment_role_arn != null
    error_message = "Set terraform_deployment_role_arn when create_terraform_deployment_role is false."
  }
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the GitHub ECR role may push to."
  type        = list(string)
  default     = []
}

variable "enable_ecr_role" {
  description = "Create a separate GitHub OIDC role for ECR image push/pull."
  type        = bool
  default     = true
}

variable "apprunner_service_arns" {
  description = "App Runner service ARNs the GitHub ECR role may deploy (start-deployment, describe)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for IAM resources."
  type        = map(string)
  default     = {}
}
