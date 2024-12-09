terraform {
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }

  }
}

provider "aws" {
  region = "ca-central-1"
}

module "vpc" {
  source            = "../../../vpc"
  name              = "vpc"
  billing_tag_value = "cal"
  availability_zones = 3
  cidrsubnet_newbits = 8
  enable_eip        = false
}

module "rds" {
  source                  = "../../../rds"
  name                    = "test-rds"
  backup_retention_period = 7
  billing_tag_value       = "cal"
  database_name           = "foo"
  engine_version          = "13.3"
  password                = "12345678901234567"
  username                = "calvin"
  preferred_backup_window = "07:00-09:00"
  subnet_ids              = module.vpc.public_subnet_ids
  vpc_id                  = module.vpc.vpc_id
}

resource "aws_ecr_repository" "test" {
  name = "hello-world"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Terraform  = "true"
    CostCentre = "cal"
  }
}

data "aws_iam_policy_document" "test" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

module "lambda" {
  source            = "../../../lambda"
  name              = "test-lambda"
  image_uri         = "${aws_ecr_repository.test.repository_url}:latest"
  ecr_arn           = aws_ecr_repository.test.arn
  billing_tag_value = "cal"
  policies          = [data.aws_iam_policy_document.test.json]

}


resource "aws_security_group" "this" {
  description = "foo"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Terraform  = "true"
    CostCentre = "cal"
  }

}

module "lambda_vpc" {
  source            = "../../../lambda"
  name              = "test-lambda"
  image_uri         = "${aws_ecr_repository.test.repository_url}:latest"
  ecr_arn           = aws_ecr_repository.test.arn
  billing_tag_value = "cal"
  vpc = {
    subnet_ids         = module.vpc.public_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }

}

module "oicd_role" {
  source            = "../../../gh_oidc_role"
  billing_tag_value = "cal"
  roles = [{
    name      = "test"
    repo_name = "foo"
    claim     = "*"

  }]
}
