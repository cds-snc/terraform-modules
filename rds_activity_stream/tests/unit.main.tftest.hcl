provider "aws" {
  region = "ca-central-1"
}

variables {
  rds_stream_name = "terraform-tests"
  rds_cluster_arn = "arn:aws:rds:ca-central-1:123456789012:cluster:test-cluster"
}

run "default_values" {
  command = plan

  assert {
    condition     = aws_rds_cluster_activity_stream.activity_stream.mode == "async"
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_activity_stream.activity_stream.resource_arn == "arn:aws:rds:ca-central-1:123456789012:cluster:test-cluster"
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_rds_cluster_activity_stream.activity_stream.resource_arn == "arn:aws:rds:ca-central-1:123456789012:cluster:test-cluster"
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.activity_stream.name == "terraform-tests-${local.resource_name_suffix}"
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_lambda_layer_version.decrypt_deps.compatible_runtimes == toset(["python3.12"])
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_lambda_function.decrypt.function_name == "terraform-tests-decrypt-${local.resource_name_suffix}"
    error_message = "Attribute not match expected value"
  }

  assert {
    condition     = aws_lambda_function.decrypt.runtime == "python3.12"
    error_message = "Attribute not match expected value"
  }
}

run "input_validation" {
  command = plan

  variables {
    activity_stream_mode = "foo"
    rds_stream_name      = "An Invalid Stream Name"
  }

  expect_failures = [
    var.activity_stream_mode,
    var.rds_stream_name,
  ]
}