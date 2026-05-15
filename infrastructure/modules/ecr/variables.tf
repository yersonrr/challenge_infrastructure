variable "name" {
  description = "Name prefix for the ECR repository."
  type        = string
}

variable "environment" {
  description = "Environment used in resource names and tags."
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Scan images on push for vulnerabilities."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain (lifecycle policy)."
  type        = number
  default     = 10
}

variable "ci_principal_arns" {
  description = "IAM principal ARNs allowed to push and pull images (e.g. GitHub Actions OIDC role)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
