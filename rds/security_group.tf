resource "aws_security_group" "proxy" {
  description = "RDS Proxy security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}_rds_proxy_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds" {
  for_each                 = var.sg_ids
  description              = "ingress-${each.value}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy.id
  source_security_group_id = each.value
}
