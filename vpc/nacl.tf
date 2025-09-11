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
  cidr_block     = "0.0.0.0/0"
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
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}

resource "aws_network_acl_rule" "block_ssh_egress" {
  count          = var.block_ssh ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 52
  egress         = true
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "block_rdp_egress" {
  count          = var.block_rdp ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 53
  egress         = true
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}

# Allow an HTTPS request out of the VPC
resource "aws_network_acl_rule" "https_request_egress_443" {
  count          = var.allow_https_request_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 60
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "https_request_out_egress_ephemeral" {
  count          = var.allow_https_request_out ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 61
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow an HTTPS response to a request that leaves the VPC
resource "aws_network_acl_rule" "https_request_out_response_ingress_443" {
  count          = var.allow_https_request_out_response ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 62
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "https_request_out_response_ingress_ephemeral" {
  count          = var.allow_https_request_out_response ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 63
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow an HTTPS request into the VPC
resource "aws_network_acl_rule" "https_request_in_ingress_443" {
  count          = var.allow_https_request_in ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 70
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "https_request_in_ingress_ephemeral" {
  count          = var.allow_https_request_in ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 71
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow an HTTPS response to a request into the VPC
resource "aws_network_acl_rule" "https_request_in_response_egress_443" {
  count          = var.allow_https_request_in_response ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 72
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "https_request_in_response_egress_ephemeral" {
  count          = var.allow_https_request_in_response ? 1 : 0
  network_acl_id = aws_network_acl.main.id
  rule_number    = 73
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
