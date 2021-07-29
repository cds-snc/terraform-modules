
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${var.name}_default_sg"
  })
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  tags = merge(local.common_tags, {
    Name = "${var.name}_default_nacl"
  })
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route = []

  tags = merge(local.common_tags, {
    name = "${var.name}_default_route_table"
  })
}
