provider "aws" {
  region = "ca-central-1"
}

variables {
  lambda_runtime = "python3.8"

  cloudwatch_alarm_arns    = ["arn1", "arn2"]
  ecs_service_arns         = ["arn3", "arn4"]
  rds_cluster_arns         = ["arn5", "arn6"]
  route53_healthcheck_arns = ["arn7", "arn8"]

  schedule_startup  = "rate(5 minutes)"
  schedule_shutdown = "rate(1 minute)"
}

run "eventbridge_inputs" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.schedule["startup"].schedule_expression == "rate(5 minutes)"
    error_message = "Startup schedule did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.schedule["shutdown"].schedule_expression == "rate(1 minute)"
    error_message = "Shutdown schedule did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_event_target.schedule["startup"].input == "{\"action\":\"startup\"}"
    error_message = "Startup target input did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_event_target.schedule["shutdown"].input == "{\"action\":\"shutdown\"}"
    error_message = "Shutdown target input did not match expected value"
  }
}

run "lambda_inputs" {
  command = plan

  assert {
    condition     = aws_lambda_function.schedule.runtime == "python3.8"
    error_message = "Lambda runtime does not match expected value"
  }

  assert {
    condition = aws_lambda_function.schedule.environment[0].variables == tomap({
      CLOUDWATCH_ALARM_ARNS    = "arn1,arn2"
      ECS_SERVICE_ARNS         = "arn3,arn4"
      RDS_CLUSTER_ARNS         = "arn5,arn6"
      ROUTE53_HEALTHCHECK_ARNS = "arn7,arn8"
    })
    error_message = "Lambda environment variables do not match expected values"
  }
}
