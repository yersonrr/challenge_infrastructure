module "network" {
  source = "../../modules/network"

  name        = var.project_name
  environment = var.environment
}
