module "security" {
  source = "../../modules/security"

  name        = var.project_name
  environment = var.environment

  apprunner_service_arn = module.apprunner.service_arn

  rate_limit           = var.waf_rate_limit
  enable_ip_reputation = var.waf_enable_ip_reputation
  enable_bot_control   = var.waf_enable_bot_control

  security_auditor_role_arns = var.security_auditor_role_arns
}
