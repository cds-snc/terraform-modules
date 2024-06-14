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
    condition     = aws_ssm_parameter.sentinel_forwarder_auth.name == "sentinel-forwarder-auth"
    error_message = "Attribute does not match expected value"
  }

  assert {
    condition = aws_ssm_parameter.sentinel_forwarder_auth.value == chomp(<<-EOT
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
