resource "aws_security_group" "proxy" {
  description = "RDS Proxy security group used to allow communication from other resources"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}_rds_proxy_sg"
  }

  ingress {
    to_port   = 5432
    from_port = 5432
    protocol  = "TCP"
    self      = true
  }

  lifecycle {
    create_before_destroy = true
  }
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
