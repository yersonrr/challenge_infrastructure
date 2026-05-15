module "ecr" {
  source = "../../modules/ecr"

  name        = var.project_name
  environment = var.environment

  ci_principal_arns = var.ecr_ci_role_arns
}
