/* 
* # Sentinel forwarder
*
* This module sets up a Lambda that forwards AWS logs to Microsoft Sentinel. It is a light wrapper on the code in
* https://github.com/cds-snc/aws-sentinel-connector-layer and connects it to its triggers:
*
* * **Security Hub findings**, through EventBridge rules (`event_rule_names`).
* * **CloudWatch Logs**, through subscription filters on the log groups in `cloudwatch_log_arns`. Each log event becomes
*   one row in Sentinel.
*
* ## Choosing the API
*
* The layer carries both Azure ingestion APIs and picks one per Lambda, from the inputs you set:
*
* * **v1, the Data Collector API.** Set `customer_id` and `shared_key`. Microsoft ended support for this API on
*   2026-09-14. Data lands in the legacy `*_CL` tables.
* * **v2, the Logs Ingestion API.** Set `dce_endpoint` and `dcr_config` — both, or the layer stays on v1 — plus
*   `azure_client_id` and `azure_tenant_id`, and one of the two sign-in methods below. Data lands in the tables behind
*   those data collection rules (DCRs).
*
* v2 needs layer version **270 or later**. Earlier versions are built for CPython 3.12, and this module runs the Lambda
* on `python3.13`, so every v2 delivery fails — while the Lambda still reports `Errors: 0`.
*
* `dcr_config` maps the layer's log type to the DCR that accepts it. The keys must be `AWSSecurityHub` and/or
* `AWSCloudWatchLog`:
*
* ```hcl
* dcr_config = {
*   AWSCloudWatchLog = {
*     dcrImmutableId = "dcr-..."
*     streamName     = "Custom-AWSCloudWatchLog_v2_Input"
*   }
* }
* ```
*
* ## Signing in to Azure on v2
*
* * **Client secret.** Set `azure_client_secret` for an Entra app registration. It is the simplest setup: the secret is
*   held in SSM. You then own a secret that expires and has to be rotated.
* * **No stored secret (Cognito).** Set `cognito_identity_pool_id` and `cognito_developer_provider_name`. The Lambda's
*   IAM role asks a Cognito identity pool for an OpenID token and presents it to Microsoft Entra ID as a client
*   assertion for a user-assigned managed identity. Nothing is stored anywhere. It needs the one-time setup below.
*
* If both are set, the client secret is used.
*
* ### Cognito setup
*
* Do these in order. The pool has to be in the same AWS account as the Lambda — identity pools have no resource policy,
* so one cannot be called from another account. One pool serves every forwarder in an account, so skip steps 1 and 2 if
* the account already has one.
*
* 1. **Create the pool** in the Lambda's account, and apply:
*
*    ```hcl
*    resource "aws_cognito_identity_pool" "sentinel_forwarder" {
*      identity_pool_name               = "sentinel-forwarder"
*      allow_unauthenticated_identities = false
*      developer_provider_name          = "azure-sentinel-access"
*    }
*    ```
*
*    Changing `developer_provider_name` later replaces the pool, which gives it a new id and breaks step 3.
*
* 2. **Mint the identity**, once, with credentials in that account:
*
*    ```sh
*    aws cognito-identity get-open-id-token-for-developer-identity \
*      --identity-pool-id <pool id> \
*      --logins azure-sentinel-access=<managed identity client id> \
*      --query IdentityId --output text
*    ```
*
*    The value after `azure-sentinel-access=` must be the managed identity's **client id**, because that is what the
*    Lambda sends; any other value creates an identity the Lambda never uses. The output is the `IdentityId`. Running
*    the command again returns the same one.
*
* 3. **Trust it in Azure.** On the user-assigned managed identity, add a federated credential:
*
*    | Field | Value |
*    | --- | --- |
*    | Issuer | `https://cognito-identity.amazonaws.com` |
*    | Audience | the pool id |
*    | Subject | the `IdentityId` from step 2 |
*
*    Give the identity **Monitoring Metrics Publisher** on each DCR it writes to. `Owner` is not enough: ingestion is a
*    data action, and `Owner` grants none.
*
* 4. **Cut over.** Set `dce_endpoint`, `dcr_config`, `azure_client_id`, `azure_tenant_id`, `cognito_identity_pool_id`
*    (the pool's `id`) and `cognito_developer_provider_name`, and bump `layer_arn` to 270 or later. You can leave
*    `customer_id` and `shared_key` in place during the cutover: the layer ignores them on v2, so rolling back means
*    removing the v2 inputs. Remove them once v2 is confirmed.
*
*    Do not do this before step 3 — until Azure trusts the pool, every delivery fails.
*
* ## Checking that it delivers
*
* The forwarder catches its own exceptions, so `Errors` stays at 0 even when nothing reaches Sentinel. After a change,
* check the destination table for new rows, and read the Lambda's own log for an `Uploaded N entries` line.
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
  # The same three every Lambda module in this repository skips, and for the
  # same reasons — see notify_slack and schedule_shutdown, which list them in a
  # .checkov.yml. Inline here instead, because this module is scanned through
  # ecs/ rather than a directory of its own, so a suppression in ecs/ would
  # record the justification in the wrong module and would not follow if
  # sentinel_forwarder were ever added to the scan matrix itself.
  #
  # checkov:skip=CKV_AWS_115:Lambda does not need function-level concurrent execution limit
  # checkov:skip=CKV_AWS_116:Lambda Dead Letter Queue not required; a failed delivery is retried by the event source
  # checkov:skip=CKV_AWS_117:Lambda does not need to be in a VPC; it reaches only AWS APIs and the Azure ingestion endpoint

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
