###
# Private route table resources
###
resource "aws_route_table" "private" {
  count  = local.max_subnet_length
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_route_table_${count.index}"
  })
}

resource "aws_route" "private_nat_gateway" {
  count                  = local.max_subnet_length
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

###
# Public route table resources
###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_route_table"
  })
}
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id

  timeouts {
    create = "5m"
  }
}
