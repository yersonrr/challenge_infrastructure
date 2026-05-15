output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.network.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for RDS and App Runner VPC connector."
  value       = aws_subnet.private_subnet[*].id
}

output "security_group_ids" {
  description = "Security group IDs for App Runner VPC connector and database workloads."
  value = {
    app_runner_vpc_connector = aws_security_group.app_runner_vpc_connector.id
    database                 = aws_security_group.database.id
  }
}

output "public_subnet_ids" {
  description = "Public subnet IDs (NAT gateways, internet-facing supporting resources)."
  value       = aws_subnet.public_subnet[*].id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.network.cidr_block
}

output "availability_zones" {
  description = "Availability zones used by subnets in this module."
  value       = local.availability_zones
}
