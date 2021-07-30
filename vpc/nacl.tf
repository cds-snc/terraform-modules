resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)

  tags = merge(local.common_tags, {
    Name = "${var.name}_main_nacl"
  })
}

resource "aws_network_acl_rule" "block_ssh" {
  count          = var.block_ssh ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 50
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "block_rdp" {
  count          = var.block_rdp ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 51
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 3389
  to_port        = 3389
}
