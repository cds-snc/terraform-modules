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

  billing_tag_value = "Test"
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

####################################################################################
# Outputs
####################################################################################

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "security_group_id" {
  value = aws_security_group.simple.id
}

output "task_role_arn" {
  value = aws_iam_role.simple.arn
}

output "task_exec_role_arn" {
  value = aws_iam_role.simple.arn
}