provider "aws" {
  region = "ca-central-1"
}

variables {
  cloudwatch_alarm_arns    = ["arn1", "arn2"]
  ecs_service_arns         = ["arn3", "arn4"]
  rds_cluster_arns         = ["arn5", "arn6"]
  route53_healthcheck_arns = ["arn7", "arn8"]
}

run "iam_inputs" {
  command = plan

  assert {
    condition     = strcontains(data.aws_iam_policy_document.cloudwatch_alarm_policy[0].json, "\"Resource\": [\n        \"arn2\",\n        \"arn1\"\n      ]\n")
    error_message = "CloudWatch alarm policy does not have expected resources"
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.ecs_service_policy[0].json, "\"Resource\": [\n        \"arn4\",\n        \"arn3\"\n      ]\n")
    error_message = "ECS service policy does not have expected resources"
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.rds_cluster_policy[0].json, "\"Resource\": [\n        \"arn6\",\n        \"arn5\"\n      ]\n")
    error_message = "RDS cluster policy does not have expected resources"
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.route53_healthcheck_policy[0].json, "\"Resource\": [\n        \"arn8\",\n        \"arn7\"\n      ]\n")
    error_message = "Route53 healthcheck policy does not have expected resources"
  }
}
