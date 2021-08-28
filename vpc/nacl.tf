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

resource "aws_network_acl_rule" "https_ingress" {
  count          = var.allow_https_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 60
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "https_egress" {
  count          = var.allow_https_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 61
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# NAT gateway uses ephemeral ports to translate the request and response
# source/destination IP addresses (Port Address Translation)
resource "aws_network_acl_rule" "ephemeral_ingress" {
  count          = var.allow_https_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 62
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "ephemeral_egress" {
  count          = var.allow_https_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 63
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 1024
  to_port        = 65535
}
