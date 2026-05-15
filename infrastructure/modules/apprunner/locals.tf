locals {
  service_name = "${var.name}-${var.environment}-api"

  common_tags = merge(
    {
      Module      = "apprunner"
      Environment = var.environment
    },
    var.tags
  )

  # Map each JSON key in the pre-created secret to an App Runner environment variable.
  runtime_environment_secrets = {
    for key in var.env_secret_keys : key => "${var.env_secret_manager_arn}:${key}::"
  }
}
