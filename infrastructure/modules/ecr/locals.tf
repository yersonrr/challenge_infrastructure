locals {
  repository_name = "${var.name}-${var.environment}-app"

  common_tags = merge(
    {
      Module      = "ecr"
      Environment = var.environment
    },
    var.tags
  )
}
