provider "aws" {
  region = var.region

  assume_role {
    role_arn = var.role_arn
  }

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
