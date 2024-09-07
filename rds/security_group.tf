###
# Security group for the proxy and rds database to talk to each other
###
resource "aws_security_group" "rds" {
  name   = local.security_group_name
  vpc_id = var.vpc_id

  description = "The Security group that allows communication between the ${local.security_group_desc_target} and the database"

  tags = merge(local.common_tags, {
    Name = local.security_group_name
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      description
    ]
  }
}

resource "aws_security_group_rule" "rds_ingress" {
  description       = "Ingress to the database"
  type              = "ingress"
  from_port         = local.database_port
  to_port           = local.database_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_egress" {
  description       = "Egress from the database"
  type              = "egress"
  from_port         = local.database_port
  to_port           = local.database_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.rds.id
}
