resource "aws_apprunner_service" "api" {
  service_name = local.service_name

  source_configuration {
    auto_deployments_enabled = var.auto_deployments_enabled

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access.arn
    }

    image_repository {
      image_identifier      = "${var.ecr_repository_url}:${var.image_tag}"
      image_repository_type = "ECR"

      image_configuration {
        port = tostring(var.container_port)

        runtime_environment_secrets = local.runtime_environment_secrets
      }
    }
  }
  
  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  dynamic "network_configuration" {
    for_each = var.enable_vpc_connector ? [1] : []
    content {
      egress_configuration {
        egress_type       = "VPC"
        vpc_connector_arn = aws_apprunner_vpc_connector.main[0].arn
      }
    }
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    healthy_threshold   = 1
    unhealthy_threshold = 5
    interval            = 10
    timeout             = 5
  }

  tags = merge(local.common_tags, {
    Name = local.service_name
  })

  depends_on = [
    aws_iam_role_policy.apprunner_ecr_access,
    aws_iam_role_policy.apprunner_instance
  ]
}
