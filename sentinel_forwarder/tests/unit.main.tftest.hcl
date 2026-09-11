provider "aws" {
  region = "ca-central-1"
}

variables {
  function_name = "sentinel-forwarder"
  customer_id   = "bruce"
  shared_key    = "manbat"
}

run "default_values" {
  command = plan

  assert {
    condition     = aws_ssm_parameter.sentinel_forwarder_auth[0].name == "sentinel-forwarder-auth"
    error_message = "Attribute does not match expected value"
  }

  assert {
    condition = aws_ssm_parameter.sentinel_forwarder_auth[0].value == chomp(<<-EOT
    CUSTOMER_ID=bruce
    SHARED_KEY=manbat
    EOT
    )
    error_message = "Attribute does not match expected value"
  }

  assert {
    condition     = length(aws_lambda_permission.sentinel_forwarder_cloudwatch_log_subscription) == 0
    error_message = "Resource should not be created"
  }

  assert {
    condition     = length(aws_lambda_permission.sentinel_forwarder_events) == 0
    error_message = "Resource should not be created"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.sentinel_forwarder) == 0
    error_message = "Resource should not be created"
  }

  assert {
    condition     = length(aws_lambda_permission.sentinel_forwarder_s3_triggers) == 0
    error_message = "Resource should not be created"
  }

  assert {
    condition     = length(aws_s3_bucket_notification.sentinel_forwarder_trigger_notification) == 0
    error_message = "Resource should not be created"
  }
}

# A caller that supplies none of the v2 inputs must be indistinguishable from
# one built before they existed. This is the whole backward-compatibility claim:
# the nested use in ecs/ resolves this module from the repo, so a v1 consumer
# picks up these changes whether or not it bumps a pinned version.
run "v1_carries_no_v2_variables" {
  command = plan

  # Asserted through the output, not through the resource. The Lambda's own
  # environment attribute is unknown at plan whenever it carries the SSM ARN,
  # and one unknown value makes the whole map unknown — so this, the central
  # backward-compatibility claim, silently cannot be checked on the resource.
  assert {
    condition = output.lambda_environment_keys == tolist([
      "LOG_TYPE",
      "SENTINEL_AUTH_PARAMS_ARN",
    ])
    error_message = "A v1 forwarder must carry exactly LOG_TYPE and SENTINEL_AUTH_PARAMS_ARN, and no v2 variable"
  }

  assert {
    condition     = length(aws_ssm_parameter.sentinel_forwarder_auth) == 1
    error_message = "A v1 forwarder must still hold its secrets in SSM"
  }

  assert {
    condition     = length(aws_iam_role_policy.sentinel_forwarder_cognito) == 0
    error_message = "A v1 forwarder configures no identity pool and must be granted nothing on one"
  }
}

# The secretless Logs Ingestion path: no SSM parameter at all, and therefore no
# SENTINEL_AUTH_PARAMS_ARN for the wrapper to read at cold start.
run "v2_cognito_is_secretless" {
  command = plan

  variables {
    customer_id  = ""
    shared_key   = ""
    dce_endpoint = "https://sentinel-forwarder-v2.canadacentral-1.ingest.monitor.azure.com"
    dcr_config = {
      AWSSecurityHub = {
        dcrImmutableId = "dcr-securityhub"
        streamName     = "Custom-AWSSecurityHub_v2_CL"
      }
      AWSCloudWatchLog = {
        dcrImmutableId = "dcr-cloudwatch"
        streamName     = "Custom-AWSCloudWatchLog_v2_CL"
      }
    }
    azure_client_id                 = "9fd2a8dc-1698-4291-a71f-19ddc3cef71f"
    azure_tenant_id                 = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"
    cognito_identity_pool_id        = "ca-central-1:754cc6c0-afac-48e9-8f0e-10abe6aa1270"
    cognito_developer_provider_name = "azure-sentinel-access"
  }

  assert {
    condition     = length(aws_ssm_parameter.sentinel_forwarder_auth) == 0
    error_message = "The secretless path must create no SSM parameter"
  }

  assert {
    condition     = !contains(keys(aws_lambda_function.sentinel_forwarder.environment[0].variables), "SENTINEL_AUTH_PARAMS_ARN")
    error_message = "Without an SSM parameter the wrapper must not be handed an ARN to read"
  }

  assert {
    condition = tomap(aws_lambda_function.sentinel_forwarder.environment[0].variables) == tomap({
      LOG_TYPE                        = "ApplicationLog"
      DCE_ENDPOINT                    = "https://sentinel-forwarder-v2.canadacentral-1.ingest.monitor.azure.com"
      DCR_CONFIG                      = "{\"AWSCloudWatchLog\":{\"dcrImmutableId\":\"dcr-cloudwatch\",\"streamName\":\"Custom-AWSCloudWatchLog_v2_CL\"},\"AWSSecurityHub\":{\"dcrImmutableId\":\"dcr-securityhub\",\"streamName\":\"Custom-AWSSecurityHub_v2_CL\"}}"
      AZURE_CLIENT_ID                 = "9fd2a8dc-1698-4291-a71f-19ddc3cef71f"
      AZURE_TENANT_ID                 = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"
      COGNITO_IDENTITY_POOL_ID        = "ca-central-1:754cc6c0-afac-48e9-8f0e-10abe6aa1270"
      COGNITO_DEVELOPER_PROVIDER_NAME = "azure-sentinel-access"
    })
    error_message = "The v2 environment must carry the exact keys the layer reads, with the DCR config as JSON"
  }

  # The layer keys DCR_CONFIG by log type and reads dcrImmutableId/streamName
  # verbatim. Renaming either here breaks ingestion with a log line, not a plan
  # error, so assert the shape survived jsonencode.
  assert {
    condition     = jsondecode(aws_lambda_function.sentinel_forwarder.environment[0].variables["DCR_CONFIG"])["AWSSecurityHub"]["dcrImmutableId"] == "dcr-securityhub"
    error_message = "DCR_CONFIG must keep the attribute names the layer reads"
  }

  assert {
    condition     = length(aws_iam_role_policy.sentinel_forwarder_cognito) == 1
    error_message = "The secretless path needs the Cognito grant; it is the Lambda's only credential"
  }

  # Derived from the caller's own account, because an identity pool has no
  # resource policy and so can never be called cross-account.
  assert {
    condition     = data.aws_iam_policy_document.sentinel_forwarder_cognito[0].statement[0].resources == toset(["arn:aws:cognito-identity:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identitypool/ca-central-1:754cc6c0-afac-48e9-8f0e-10abe6aa1270"])
    error_message = "The Cognito grant must be scoped to the configured pool in this account"
  }
}

# The client-secret path is the other half of B5's table: a secret wins when one
# is present, and it is the one v2 value that belongs in SSM rather than in a
# plainly visible Lambda variable.
run "v2_client_secret_uses_ssm" {
  command = plan

  variables {
    customer_id  = ""
    shared_key   = ""
    dce_endpoint = "https://example.canadacentral-1.ingest.monitor.azure.com"
    dcr_config = {
      AWSSecurityHub = {
        dcrImmutableId = "dcr-securityhub"
        streamName     = "Custom-AWSSecurityHub_v2_CL"
      }
    }
    azure_client_id     = "9fd2a8dc-1698-4291-a71f-19ddc3cef71f"
    azure_tenant_id     = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"
    azure_client_secret = "shhh"
  }

  assert {
    condition     = aws_ssm_parameter.sentinel_forwarder_auth[0].value == "AZURE_CLIENT_SECRET=shhh"
    error_message = "The client secret is the only thing left worth holding in SSM"
  }

  # That the secret is not ALSO a Lambda variable cannot be asserted here — this
  # run has an SSM parameter, so the environment map is unknown at plan. The
  # secretless run above asserts its key set exactly, and AZURE_CLIENT_SECRET is
  # absent from the single expression that builds the map for both.

  assert {
    condition     = length(aws_iam_role_policy.sentinel_forwarder_cognito) == 0
    error_message = "No pool is configured, so nothing should be granted on one"
  }
}

# Setting one of the pair alone leaves the layer on v1 silently — it tests for
# both. Refuse it at plan time rather than discover it as missing data.
run "half_configured_v2_is_refused" {
  command = plan

  variables {
    dce_endpoint = "https://example.canadacentral-1.ingest.monitor.azure.com"
  }

  expect_failures = [
    aws_lambda_function.sentinel_forwarder,
  ]
}

run "v2_without_an_auth_method_is_refused" {
  command = plan

  variables {
    customer_id  = ""
    shared_key   = ""
    dce_endpoint = "https://example.canadacentral-1.ingest.monitor.azure.com"
    dcr_config = {
      AWSSecurityHub = {
        dcrImmutableId = "dcr-securityhub"
        streamName     = "Custom-AWSSecurityHub_v2_CL"
      }
    }
    azure_client_id = "9fd2a8dc-1698-4291-a71f-19ddc3cef71f"
    azure_tenant_id = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"
  }

  expect_failures = [
    aws_lambda_function.sentinel_forwarder,
  ]
}

run "no_configuration_at_all_is_refused" {
  command = plan

  variables {
    customer_id = ""
    shared_key  = ""
  }

  expect_failures = [
    aws_lambda_function.sentinel_forwarder,
  ]
}
