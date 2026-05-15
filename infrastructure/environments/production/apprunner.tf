module "apprunner" {
  source = "../../modules/apprunner"

  name        = var.project_name
  environment = var.environment
  region      = var.region

  ecr_repository_url     = module.ecr.repository_url
  ecr_repository_arn     = module.ecr.repository_arn
  image_tag              = var.app_image_tag
  env_secret_manager_arn = var.env_secret_manager_arn

  vpc_id                           = module.network.vpc_id
  private_subnet_ids               = module.network.private_subnet_ids
  vpc_connector_security_group_ids = [module.network.security_group_ids.app_runner_vpc_connector]

  dynamodb_table_arns = values(module.db.table_arns)

  min_size        = var.apprunner_min_size
  max_size        = var.apprunner_max_size
  max_concurrency = var.apprunner_max_concurrency
}
