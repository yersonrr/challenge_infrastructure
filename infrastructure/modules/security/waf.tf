resource "aws_wafv2_web_acl" "waf" {
  name  = local.web_acl_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # 100 requests per 5 minutes per IP (WAF rate-based rules aggregate per IP over 5 minutes).
  rule {
    name     = "rate-limit-per-ip"
    priority = local.rule_priority.rate_limit

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-${var.environment}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.enable_ip_reputation ? [1] : []
    content {
      name     = "aws-ip-reputation"
      priority = local.rule_priority.ip_reputation

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${var.environment}-ip-reputation"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.enable_bot_control ? [1] : []
    content {
      name     = "aws-bot-control"
      priority = local.rule_priority.bot_control

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs {
            aws_managed_rules_bot_control_rule_set {
              inspection_level = var.bot_control_inspection_level
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${var.environment}-bot-control"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.web_acl_name
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = local.web_acl_name
  })
}

resource "aws_wafv2_web_acl_association" "apprunner" {
  resource_arn = var.apprunner_service_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
