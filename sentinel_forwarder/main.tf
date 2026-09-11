/* 
* # Sentinel forwarder
*
* This module sets up a lambda that will forward AWS logs to Azure Sentinel. 
* It is a light wrapper on the code found here (https://github.com/cds-snc/aws-sentinel-connector-layer) and
* just stitches together the code with the triggers.
*
* Triggers can be EventHub rules, S3 ObjectCreated events, or CloudWatch Log Subscriptions. The following log types are supported:
* - CloudTrail (.json.gz)
* - Load balancer (.log.gz)
* - VPC flow logs (.log.gz)
* - WAF ACL (.gz)
* - GuardDuty
* - SecurityHub (via EventHub)
* - Generic application json logs
*
* The layer carries two Azure APIs and picks between them per Lambda, on the presence of the environment variables this
* module sets. Which one you get is decided by which inputs you supply:
*
* * **v1, the Data Collector API.** Set `customer_id` and `shared_key`. They are held in an SSM `SecureString` and loaded
*   at cold start. Data lands in the legacy `*_CL` tables.
* * **v2, the Logs Ingestion API.** Set `dce_endpoint` and `dcr_config` — both, or the layer stays on v1 — plus
*   `azure_client_id` and `azure_tenant_id`. Data lands in the tables behind those DCRs.
*
* v2 then takes one of two auth paths. Supplying `azure_client_secret` selects the client-secret path and takes
* precedence. Supplying `cognito_identity_pool_id` and `cognito_developer_provider_name` instead selects the secretless
* path: this module grants the Lambda `cognito-identity:GetOpenIdTokenForDeveloperIdentity` on that pool, the layer
* exchanges the resulting OIDC token for an Entra token as a user-assigned managed identity, and nothing is stored
* anywhere. The identity pool must be in this Lambda's own AWS account — identity pools have no resource policy, so one
* cannot be called cross-account.
*
* A caller that sets none of the v2 inputs is on v1 and behaves exactly as it did before they existed.
*
* AWS logs are automatically assigned a LogType. Custom application logs are given the log type defined through
* `var.log_type`, which applies on v1 only — under v2 the destination comes from `dcr_config`. They also need to be
* nested inside a json object with the key, `application_log`. ex: `{'application_log': {'foo': 'bar'}}` for the layer
* code to forward it to Azure Sentinel.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.46.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_lambda_function" "sentinel_forwarder" {
  function_name = var.function_name
  description   = "Lambda function to forward AWS logs to Azure Sentinel"

  filename    = data.archive_file.sentinel_forwarder.output_path
  handler     = "sentinel_forwarder.lambda_handler"
  runtime     = "python3.13"
  timeout     = 30
  memory_size = 128

  role             = aws_iam_role.sentinel_forwarder_lambda.arn
  source_code_hash = filebase64sha256(data.archive_file.sentinel_forwarder.output_path)

  environment {
    variables = local.lambda_environment
  }

  lifecycle {
    precondition {
      condition     = (var.dce_endpoint != "") == (length(var.dcr_config) > 0)
      error_message = "dce_endpoint and dcr_config must be set together. The layer routes to the Logs Ingestion API only when both are present, so setting one alone leaves the forwarder on v1 with no error."
    }

    precondition {
      condition     = !local.v2_enabled || (var.azure_client_id != "" && var.azure_tenant_id != "")
      error_message = "azure_client_id and azure_tenant_id are required when dce_endpoint and dcr_config are set; the v2 path has no other way to name the identity it authenticates as."
    }

    precondition {
      condition     = !local.v2_enabled || var.azure_client_secret != "" || (var.cognito_identity_pool_id != "" && var.cognito_developer_provider_name != "")
      error_message = "The v2 path needs an auth method: either azure_client_secret, or both cognito_identity_pool_id and cognito_developer_provider_name for the secretless path."
    }

    precondition {
      condition     = local.v2_enabled || (var.customer_id != "" && var.shared_key != "")
      error_message = "customer_id and shared_key are required on the v1 Data Collector API path. Set dce_endpoint and dcr_config to move this forwarder to v2 instead."
    }
  }

  tracing_config {
    mode = "Active"
  }

  layers = [var.layer_arn]

  depends_on = [
    aws_iam_role_policy_attachment.sentinel_forwarder_lambda,
    aws_cloudwatch_log_group.sentinel_forwarder_lambda,
  ]

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

data "archive_file" "sentinel_forwarder" {
  type        = "zip"
  source_file = "${path.module}/wrapper/sentinel_forwarder.py"
  output_path = "/tmp/sentinel_forwarder.py.zip"
}

#
# CloudWatch Log Subscriptions
#
resource "aws_lambda_permission" "sentinel_forwarder_cloudwatch_log_subscription" {
  count = length(var.cloudwatch_log_arns)

  statement_id  = "AllowExecutionFromCloudWatchLogs-${var.function_name}-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sentinel_forwarder.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = format("%s:*", var.cloudwatch_log_arns[count.index])
}

#
# Event triggers
#
resource "aws_lambda_permission" "sentinel_forwarder_events" {
  count = length(var.event_rule_names)

  statement_id   = "AllowExecutionFromEvents-${var.function_name}-${count.index}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.sentinel_forwarder.function_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_target.sentinel_forwarder[count.index].arn
  source_account = data.aws_caller_identity.current.account_id
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

  statement_id   = "AllowExecutionFromS3-${var.function_name}-${count.index}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.sentinel_forwarder.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = var.s3_sources[count.index].bucket_arn
  source_account = data.aws_caller_identity.current.account_id
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

  tags = local.common_tags
}

#
# Lambda function secrets
#
# Created only when there is something secret to hold. The secretless v2 path
# has none — the Lambda's IAM role is the whole credential — and an SSM
# parameter cannot hold an empty value anyway. The wrapper skips its cold-start
# read when SENTINEL_AUTH_PARAMS_ARN is absent.
resource "aws_ssm_parameter" "sentinel_forwarder_auth" {
  count = local.has_secrets ? 1 : 0

  name  = "${var.function_name}-auth"
  type  = "SecureString"
  value = local.secrets_body

  tags = local.common_tags
}
