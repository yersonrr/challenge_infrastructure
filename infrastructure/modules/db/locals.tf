locals {
  common_tags = merge(
    {
      Module      = "db"
      Environment = var.environment
    },
    var.tags
  )

  provisioned_capacity = var.billing_mode == "PROVISIONED" ? {
    read_capacity  = var.read_capacity
    write_capacity = var.write_capacity
  } : {}

  use_autoscaling = var.billing_mode == "PROVISIONED" && var.enable_autoscaling
}
