provider "aws" {
  region = "ca-central-1"
}

variables {
  project_name                 = "simple"
  github_repository_url        = "https://github.com/cds-snc/terraform-modules.git"
  github_personal_access_token = "this_should_be_secret"
  environment_variables = [
    {
      name  = "foo"
      value = "bar"
    }
  ]
}

run "plan" {
  command = plan

  assert {
    condition     = length(aws_codebuild_project.this.environment[0].environment_variable) == 1
    error_message = "Unexpected attribute length"
  }

  assert {
    condition     = aws_codebuild_project.this.environment[0].environment_variable[0].name == "foo"
    error_message = "Unexpected attribute value"
  }

  assert {
    condition     = aws_codebuild_project.this.environment[0].environment_variable[0].value == "bar"
    error_message = "Unexpected attribute value"
  }

  assert {
    condition     = length(aws_codebuild_project.this.vpc_config) == 0
    error_message = "VPC configuration should be omitted when VPC inputs are not provided"
  }

  assert {
    condition     = !local.is_vpc_config
    error_message = "VPC configuration should be disabled when VPC inputs are not provided"
  }
}

run "plan_with_vpc_config" {
  command = plan

  variables {
    vpc_id             = "vpc-0123456789abcdef0"
    subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
    security_group_ids = ["sg-0123456789abcdef0"]
  }

  assert {
    condition     = length(aws_codebuild_project.this.vpc_config) == 1
    error_message = "VPC configuration should be included when all VPC inputs are provided"
  }

  assert {
    condition     = aws_codebuild_project.this.vpc_config[0].vpc_id == "vpc-0123456789abcdef0"
    error_message = "Unexpected VPC ID"
  }

  assert {
    condition     = toset(aws_codebuild_project.this.vpc_config[0].subnets) == toset(["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"])
    error_message = "Unexpected subnet IDs"
  }

  assert {
    condition     = toset(aws_codebuild_project.this.vpc_config[0].security_group_ids) == toset(["sg-0123456789abcdef0"])
    error_message = "Unexpected security group IDs"
  }

  assert {
    condition     = local.is_vpc_config
    error_message = "VPC configuration should be enabled when all VPC inputs are provided"
  }
}

run "plan_with_incomplete_vpc_config" {
  command = plan

  variables {
    vpc_id     = "vpc-0123456789abcdef0"
    subnet_ids = ["subnet-0123456789abcdef0"]
  }

  assert {
    condition     = length(aws_codebuild_project.this.vpc_config) == 0
    error_message = "VPC configuration should be omitted unless all VPC inputs are provided"
  }

  assert {
    condition     = !local.is_vpc_config
    error_message = "VPC configuration should be disabled unless all VPC inputs are provided"
  }
}
