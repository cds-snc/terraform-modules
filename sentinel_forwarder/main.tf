/* 
* # Sentinel forwarder
*
* This module sets up a lambda that will forward AWS logs to Azure Sentinel. 
* It is a light wrapper on the code found here (https://github.com/cds-snc/aws-sentinel-connector-layer) and
* just stitches together the code with the triggers.
*
* Triggers can be EventHub rules or S3 ObjectCreated events. The following log types are supported:
* - CloudTrail (.json.gz)
* - Load balancer (.log.gz)
* - VPC flow logs (.log.gz)
* - WAF ACL (.gz)
* - GuardDuty
* - SecurityHub (via EventHub)
* - Generic application json logs
*
* You will need to add your Log Analytics Workspace Customer ID and Shared Key. AWS logs are automatically assigned a LogType.
* Custom application logs are given the log type defined through the `var.log_type`. They also need to be nested inside a json
* object with the key, `application_log`. ex: `{'application_log': {'foo': 'bar'}}` for the layer code to forward it to Azure Sentinel.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.46.0"
    }
  }
}

resource "aws_lambda_function" "sentinel_forwarder" {
  function_name = var.function_name
  description   = "Lambda function to forward AWS logs to Azure Sentinel"

  filename    = data.archive_file.sentinel_forwarder.output_path
  handler     = "sentinel_forwarder.lambda_handler"
  runtime     = "python3.9"
  timeout     = 30
  memory_size = 128

  role             = aws_iam_role.sentinel_forwarder_lambda.arn
  source_code_hash = filebase64sha256(data.archive_file.sentinel_forwarder.output_path)

  environment {
    variables = {
      CUSTOMER_ID = var.customer_id
      LOG_TYPE    = var.log_type
      SHARED_KEY  = var.shared_key
    }
  }

  layers = [var.layer_arn]

  depends_on = [
    aws_iam_role_policy_attachment.sentinel_forwarder_lambda,
    aws_cloudwatch_log_group.sentinel_forwarder_lambda,
  ]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}

data "archive_file" "sentinel_forwarder" {
  type        = "zip"
  source_file = "${path.module}/wrapper/sentinel_forwarder.py"
  output_path = "/tmp/sentinel_forwarder.py.zip"
}

#
# Event triggers
#
resource "aws_lambda_permission" "sentinel_forwarder_events" {
  count = length(var.event_rule_names)

  statement_id  = "AllowExecutionFromEvents-${var.function_name}-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sentinel_forwarder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_target.sentinel_forwarder[count.index].arn
}

resource "aws_cloudwatch_event_target" "sentinel_forwarder" {
  count = length(var.event_rule_names)

  target_id = "SentinelForwarderEventTarget-${count.index}"
  rule      = var.event_rule_names[count.index]
  arn       = aws_lambda_function.sentinel_forwarder.arn
}


#
# S3 triggers
#
resource "aws_lambda_permission" "sentinel_forwarder_s3_triggers" {
  count = length(var.s3_sources)

  statement_id  = "AllowExecutionFromS3-${var.function_name}-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sentinel_forwarder.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_sources[count.index].bucket_arn
}

resource "aws_s3_bucket_notification" "sentinel_forwarder_trigger_notification" {
  count  = length(var.s3_sources)
  bucket = var.s3_sources[count.index].bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sentinel_forwarder.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_sources[count.index].filter_prefix
  }

  depends_on = [aws_lambda_permission.sentinel_forwarder_s3_triggers]
}

#
# CloudWatch: Lambda logs
#
resource "aws_cloudwatch_log_group" "sentinel_forwarder_lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = "14"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
  }
}