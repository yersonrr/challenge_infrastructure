resource "aws_apprunner_vpc_connector" "main" {
  count = var.enable_vpc_connector ? 1 : 0

  vpc_connector_name = "${var.name}-${var.environment}-connector"
  subnets            = var.private_subnet_ids
  security_groups    = var.vpc_connector_security_group_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-connector"
  })
}
