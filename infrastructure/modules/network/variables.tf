variable "name" {
  description = "Name prefix for network resources (e.g. project or app name)."
  type        = string
}

variable "environment" {
  description = "Environment label used in resource names and tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets. When null, the first N AZs in the region are used (N = length of private_subnet_cidrs)."
  type        = list(string)
  default     = null
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ). Used for NAT gateways and internet-routed workloads."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ). Host RDS and App Runner VPC connector ENIs."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) in public subnets and route private subnet egress through them."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets (lower cost; not highly available)."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Create interface/gateway VPC endpoints for private AWS API access (no NAT required for those services)."
  type        = bool
  default     = false
}

variable "vpc_endpoint_services" {
  description = "AWS service suffixes for interface endpoints (region is added automatically). Ignored when enable_vpc_endpoints is false."
  type        = list(string)
  default     = ["secretsmanager", "ssm", "ssmmessages", "ec2messages"]
}

variable "database_port" {
  description = "Database port allowed from the App Runner VPC connector security group."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Additional tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
