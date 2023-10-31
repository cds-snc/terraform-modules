/* 
* # Schedule shutdown
* Lambda function to schedule resource shutdown and startup to save costs.  The function is triggered by CloudWatch Events
* controlled by schedule expressions.   
* 
* Currently the function supports scaling the following resources:
* - CloudWatch alarms: enables/disables the alarm actions.
* - ECS services: scales the service between 0 and 1 tasks.
* - RDS clusters: stops/starts the cluster.
* - Route53 healthchecks: enables/disables the healthcheck.
*/
resource "aws_lambda_function" "schedule" {
  function_name = local.lambda_name
  description   = "Lambda function to schedule resource shutdown and startup"

  filename    = data.archive_file.schedule.output_path
  handler     = "schedule.handler"
  runtime     = var.lambda_runtime
  timeout     = 60
  memory_size = 128

  role             = aws_iam_role.schedule.arn
  source_code_hash = filebase64sha256(data.archive_file.schedule.output_path)

  environment {
    variables = {
      CLOUDWATCH_ALARM_ARNS    = join(",", var.cloudwatch_alarm_arns)
      ECS_SERVICE_ARNS         = join(",", var.ecs_service_arns)
      RDS_CLUSTER_ARNS         = join(",", var.rds_cluster_arns)
      ROUTE53_HEALTHCHECK_ARNS = join(",", var.route53_healthcheck_arns)
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = local.common_tags
}

data "archive_file" "schedule" {
  type        = "zip"
  source_file = "${path.module}/lambda/schedule.py"
  output_path = "/tmp/schedule.py.zip"
}

resource "aws_cloudwatch_log_group" "schedule" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = "14"
  tags              = local.common_tags
}

resource "aws_cloudwatch_event_target" "schedule" {
  for_each = local.schedule

  arn  = aws_lambda_function.schedule.arn
  rule = aws_cloudwatch_event_rule.schedule[each.key].id
  input = jsonencode({
    "action" : each.key,
  })
}

resource "aws_cloudwatch_event_rule" "schedule" {
  for_each = local.schedule

  name                = "${local.lambda_name}-${each.key}"
  description         = "Resource ${each.key} at '${each.value}'"
  schedule_expression = each.value
  tags                = local.common_tags
}

resource "aws_lambda_permission" "schedule" {
  for_each = local.schedule

  statement_id  = "AllowExecutionFromCloudWatch-${each.key}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.schedule.function_name
  source_arn    = aws_cloudwatch_event_rule.schedule[each.key].arn
}
