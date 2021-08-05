resource "aws_security_group" "proxy" {
  description = "RDS Proxy security group used to allow communication from other resources"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}_rds_proxy_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

###
# ingress rule added to the proxys security group allowing access from the passed in security groups
###
resource "aws_security_group_rule" "rds_ingress" {
  for_each                 = var.sg_ids
  description              = "ingress-${each.value}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy.id
  source_security_group_id = each.value
}

###
# Egress rules added to security groups that are provided to this module
###
resource "aws_security_group_rule" "rds_egress" {
  for_each                 = var.sg_ids
  description              = "egress-${each.value}"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxy.id
  security_group_id        = each.value
}

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

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"
    self      = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
