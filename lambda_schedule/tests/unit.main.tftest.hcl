provider "aws" {
  region = "ca-central-1"
}

variables {
  lambda_name                = "test"
  lambda_schedule_expression = "rate(1 day)"
}

run "default" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.this.schedule_expression == "rate(1 day)"
    error_message = "Policies should not be populated"
  }

  assert {
    condition     = length(local.policies) == 0
    error_message = "Policies should not be populated"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.s3_write) == 0
    error_message = "Policies should not be populated"
  }

  assert {
    condition     = length(aws_ecr_repository.this) == 1
    error_message = "ECR repository should be created"
  }

  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 1
    error_message = "ECR repository policy should be created"
  }
}

run "custom" {
  command = plan

  variables {
    create_ecr_repository = false
    lambda_ecr_arn        = "arn:aws:ecr:ca-central-1:123456789012:repository/test"
    lambda_image_uri      = "123456789012.dkr.ecr.ca-central-1.amazonaws.com/test"
    lambda_image_tag      = "v1"
    s3_arn_write_path     = "arn:aws:s3:::my-bucket/foo/bar*"
  }

  assert {
    condition     = local.lambda_ecr_arn == "arn:aws:ecr:ca-central-1:123456789012:repository/test"
    error_message = "ECR ARN value is incorrect"
  }

  assert {
    condition     = local.lambda_image_uri == "123456789012.dkr.ecr.ca-central-1.amazonaws.com/test:v1"
    error_message = "ECR ARN value is incorrect"
  }

  assert {
    condition     = local.policies[0] == data.aws_iam_policy_document.s3_write[0].json
    error_message = "Policies should be populated"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.s3_write) == 1
    error_message = "Policies should have been created"
  }

  assert {
    condition     = data.aws_iam_policy_document.s3_write[0].statement[0].resources == toset(["arn:aws:s3:::my-bucket/foo/bar*"])
    error_message = "Policy shoud have the correct S3 bucket ARN and path"
  }
}
