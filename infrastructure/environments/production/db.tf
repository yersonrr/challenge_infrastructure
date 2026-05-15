module "db" {
  source = "../../modules/db"

  name        = var.project_name
  environment = var.environment
}
