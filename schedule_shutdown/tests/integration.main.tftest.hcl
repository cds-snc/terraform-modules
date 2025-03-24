provider "aws" {
  region = "ca-central-1"
}

run "module_defaults" {
  command = apply

  assert {
    condition     = aws_lambda_function.schedule.runtime == "python3.13"
    error_message = "Lambda runtime does not match expected value"
  }

  assert {
    condition = aws_lambda_function.schedule.environment[0].variables == tomap({
      CLOUDWATCH_ALARM_ARNS    = ""
      ECS_SERVICE_ARNS         = ""
      RDS_CLUSTER_ARNS         = ""
      ROUTE53_HEALTHCHECK_ARNS = ""
    })
    error_message = "Lambda environment variables do not match expected values"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.cloudwatch_alarm_policy) == 0
    error_message = "IAM CloudWatch alarm policy should not exist"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.ecs_service_policy) == 0
    error_message = "IAM ECS service policy should not exist"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.rds_cluster_policy) == 0
    error_message = "IAM RDS cluster policy should not exist"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.route53_healthcheck_policy) == 0
    error_message = "IAM Route53 healthcheck policy should not exist"
  }
}
