locals {
  availability_zones = coalesce(
    var.availability_zones,
    slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  )

  common_tags = merge(
    {
      Module      = "network"
      Environment = var.environment
    },
    var.tags
  )

  # App Runner VPC connectors and RDS subnet groups require subnets in multiple AZs.
  subnet_count = length(var.private_subnet_cidrs)

  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.subnet_count) : 0
}
