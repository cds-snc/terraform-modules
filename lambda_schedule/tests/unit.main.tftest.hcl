provider "aws" {
  region = "ca-central-1"
}

variables {
  lambda_name                = "test"
  lambda_schedule_expression = "rate(1 day)"
}

run "test_case" {
  command = plan
}
