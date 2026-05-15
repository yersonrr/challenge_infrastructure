locals {
  web_acl_name = "${var.name}-${var.environment}-web-acl"

  common_tags = merge(
    {
      Module      = "security"
      Environment = var.environment
    },
    var.tags
  )

  rule_priority = {
    rate_limit    = 10
    ip_reputation = 20
    bot_control   = 30
  }
}
