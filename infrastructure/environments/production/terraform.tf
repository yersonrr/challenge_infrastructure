terraform {
  required_version = ">= 1.13.0"

  # The S3 backend cannot reference Terraform variables.
  # So using variable.bucket or variable.key returns errors.
  backend "s3" {
    bucket       = "challenge-terraform-states"
    key          = "infra_app_url/production/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
