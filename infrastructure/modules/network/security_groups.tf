resource "aws_security_group" "app_runner_vpc_connector" {
  name        = "${var.name}-${var.environment}-apprunner-vpc-connector"
  description = "Egress from App Runner VPC connector ENIs to private resources (e.g. database)."
  vpc_id      = aws_vpc.network.id

  egress {
    description = "Traffic within the VPC (database, endpoints, internal services)."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-apprunner-vpc-connector-sg"
  })
}

resource "aws_security_group" "database" {
  name        = "${var.name}-${var.environment}-database"
  description = "Database in private subnets; ingress from App Runner VPC connector only."
  vpc_id      = aws_vpc.network.id

  ingress {
    description     = "Database from App Runner VPC connector"
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_runner_vpc_connector.id]
  }

  egress {
    description = "Responses and optional outbound within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-database-sg"
  })
}
