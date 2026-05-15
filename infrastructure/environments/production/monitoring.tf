module "monitoring" {
  source = "../../modules/monitoring"

  name        = var.project_name
  environment = var.environment
  region      = var.region

  app_runner_service_name                 = module.apprunner.service_name
  app_runner_min_instances                = var.apprunner_min_size
  app_runner_max_instances                = var.apprunner_max_size
  app_runner_max_concurrency_per_instance = var.apprunner_max_concurrency

  waf_log_group_name = module.security.waf_log_group_name

  log_retention_days    = var.monitoring_log_retention_days
  enable_sns_alarms     = var.monitoring_enable_sns
  alarm_email_endpoints = var.monitoring_alarm_emails
}
