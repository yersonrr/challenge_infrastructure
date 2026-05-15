variable "name" {
  description = "Name prefix for App Runner resources."
  type        = string
}

variable "environment" {
  description = "Environment label used in resource names and tags."
  type        = string
}

variable "region" {
  description = "AWS region (used for DynamoDB endpoint and Secrets Manager ARNs)."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL from the ecr module (without tag)."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN; used to scope pull permissions (no wildcard resources)."
  type        = string
}

variable "image_tag" {
  description = "Container image tag to deploy from ECR."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the NestJS application listens on inside the container."
  type        = number
  default     = 3000
}

variable "vpc_id" {
  description = "VPC ID for the App Runner VPC connector."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the App Runner VPC connector."
  type        = list(string)
}

variable "vpc_connector_security_group_ids" {
  description = "Security group IDs for the App Runner VPC connector ENIs."
  type        = list(string)
}

variable "enable_vpc_connector" {
  description = "Attach a VPC connector for private egress (recommended when using VPC endpoints or private resources)."
  type        = bool
  default     = true
}

variable "dynamodb_table_arns" {
  description = "ARNs of DynamoDB tables the application may access."
  type        = list(string)
}

variable "env_secret_manager_arn" {
  description = "ARN of an existing Secrets Manager secret (JSON). App Runner injects keys as environment variables; create and populate this secret outside Terraform."
  type        = string
}

variable "env_secret_keys" {
  description = "JSON keys from env_secret_manager_arn to expose as App Runner environment variables (names must match keys in the secret)."
  type        = list(string)
  default = [
    "JWT_SECRET",
    "DB_ENDPOINT",
    "URLS_TABLE_NAME",
    "USERS_TABLE_NAME",
    "NODE_ENV",
  ]
}

variable "min_size" {
  description = "Minimum number of App Runner instances."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of App Runner instances."
  type        = number
  default     = 5
}

variable "max_concurrency" {
  description = "Maximum concurrent requests per instance before scaling out."
  type        = number
  default     = 100
}

variable "cpu" {
  description = "vCPU units for each instance (256, 512, 1024, 2048, 4096)."
  type        = string
  default     = "1024"
}

variable "memory" {
  description = "Memory (MiB) for each instance."
  type        = string
  default     = "2048"
}

variable "auto_deployments_enabled" {
  description = "Automatically deploy new ECR images when pushed."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
