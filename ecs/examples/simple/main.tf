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
  desired_count   = 1

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.simple.id]

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2

  task_role_arn      = aws_iam_role.simple.arn
  task_exec_role_arn = aws_iam_role.simple.arn

  billing_tag_value = "Terratest"
}

################################################################################
# Networking
################################################################################

module "vpc" {
  source = "../../../vpc/"
  name   = "simple_cluster"

  availability_zones = 1
  enable_flow_log    = false
  block_ssh          = true
  block_rdp          = true
  single_nat_gateway = true

  allow_https_request_out          = true
  allow_https_request_out_response = true

  billing_tag_value = "Terratest"
}

resource "aws_security_group" "simple" {
  # checkov:skip=CKV2_AWS_5:Security Group is attached to the ECS service
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


####################################################################################
# IAM Roles
####################################################################################

data "aws_iam_policy_document" "simple" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "simple" {
  name               = "simple"
  assume_role_policy = data.aws_iam_policy_document.simple.json
}

resource "aws_iam_role_policy_attachment" "simple" {
  role       = aws_iam_role.simple.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
