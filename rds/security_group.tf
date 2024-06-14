###
# Security group for the proxy and rds database to talk to each other
###
resource "aws_security_group" "rds_proxy" {
  name   = "${var.name}_rds_proxy_sg"
  vpc_id = var.vpc_id

  description = "The Security group that allows communication between the proxy and the database"

  tags = merge(local.common_tags, {
    Name = "${var.name}_rds_proxy_sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_proxy_ingress" {
  description       = "Proxy ingress to the database"
  type              = "ingress"
  from_port         = local.database_port
  to_port           = local.database_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.rds_proxy.id
}

resource "aws_security_group_rule" "rds_proxy_egress" {
  description       = "Proxy egress from the database"
  type              = "egress"
  from_port         = local.database_port
  to_port           = local.database_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.rds_proxy.id
}
