resource "aws_subnet" "private_subnet" {
  count = local.subnet_count

  vpc_id            = aws_vpc.network.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-private-${local.availability_zones[count.index]}"
    Tier = "private"
  })
}

resource "aws_route_table" "private_route_table" {
  count = local.subnet_count

  vpc_id = aws_vpc.network.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat_gateway[0].id : aws_nat_gateway.nat_gateway[count.index].id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-${var.environment}-private-rt-${local.availability_zones[count.index]}"
  })
}

resource "aws_route_table_association" "private_subnet" {
  count = local.subnet_count

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}
