################################################################################
# ECS Cluster
################################################################################

module "simple_cluster" {
  source = "../../"

  cluster_name    = "simple_cluster"
  service_name    = "nginx"
  task_cpu        = 256
  task_memory     = 512
  container_image = "nginx:latest"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.simple.id]

  billing_tag_value = "Terratest"
}

################################################################################
# Networking
################################################################################

module "vpc" {
  source = "../../../vpc/"
  name   = "simple_cluster"

  high_availability  = false
  enable_flow_log    = false
  block_ssh          = true
  block_rdp          = true
  single_nat_gateway = true

  allow_https_request_out          = true
  allow_https_request_out_response = true

  billing_tag_value = "Terratest"
}

resource "aws_security_group" "simple" {
  name        = "simple_cluster"
  description = "Simple ECS cluster example security group"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "simple" {
  description       = "Egress from ECS task to internet to pull the nginx image"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.simple.id
  cidr_blocks       = ["0.0.0.0/0"]
}