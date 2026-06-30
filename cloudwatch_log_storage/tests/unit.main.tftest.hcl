provider "aws" {
  region = "ca-central-1"
}

variables {
  billing_tag_value          = "test-cost-centre"
  cloudwatch_log_group_names = ["/aws/lambda/my-function", "/aws/ecs/my-service"]
  product_name               = "test-product"
}

run "default_values" {
  command = plan

  # Kinesis Firehose stream
  assert {
    condition     = aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage.name == "test-product-cloudwatch-log-storage"
    error_message = "Firehose stream name does not match expected value"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage.destination == "extended_s3"
    error_message = "Firehose stream destination does not match expected value"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage.server_side_encryption[0].enabled == true
    error_message = "Firehose stream server side encryption should be enabled"
  }

  # Subscription filters are created for each log group
  assert {
    condition     = length(aws_cloudwatch_log_subscription_filter.firehose_subscription) == 2
    error_message = "Expected one subscription filter per log group"
  }

  assert {
    condition     = aws_cloudwatch_log_subscription_filter.firehose_subscription["/aws/lambda/my-function"].log_group_name == "/aws/lambda/my-function"
    error_message = "Subscription filter log group name does not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_subscription_filter.firehose_subscription["/aws/ecs/my-service"].log_group_name == "/aws/ecs/my-service"
    error_message = "Subscription filter log group name does not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_subscription_filter.firehose_subscription["/aws/lambda/my-function"].filter_pattern == ""
    error_message = "Subscription filter should forward all logs (empty filter pattern)"
  }

  # Subscription filter name replaces slashes and underscores with hyphens
  assert {
    condition     = aws_cloudwatch_log_subscription_filter.firehose_subscription["/aws/lambda/my-function"].name == "log-storage-aws-lambda-my-function"
    error_message = "Subscription filter name does not match expected value"
  }

  # Athena queries are NOT created when workgroup/database not provided
  assert {
    condition     = length(aws_athena_named_query.cloudwatch_create_table) == 0
    error_message = "Athena create table query should not be created when workgroup/database not provided"
  }

  assert {
    condition     = length(aws_athena_named_query.cloudwatch_view_logs) == 0
    error_message = "Athena view logs query should not be created when workgroup/database not provided"
  }

  # IAM roles
  assert {
    condition     = aws_iam_role.cloudwatch_log_storage.name == "test-product-cloudwatch-log-storage"
    error_message = "CloudWatch IAM role name does not match expected value"
  }

  assert {
    condition     = aws_iam_role.firehose_cloudwatch_log_storage.name == "test-product-firehose-cloudwatch-log-storage"
    error_message = "Firehose IAM role name does not match expected value"
  }
}

run "athena_enabled" {
  command = plan

  variables {
    athena_workgroup_name = "my-workgroup"
    athena_database_name  = "my-database"
  }

  # Athena queries ARE created when workgroup and database are provided
  assert {
    condition     = length(aws_athena_named_query.cloudwatch_create_table) == 1
    error_message = "Athena create table query should be created when workgroup/database provided"
  }

  assert {
    condition     = length(aws_athena_named_query.cloudwatch_view_logs) == 1
    error_message = "Athena view logs query should be created when workgroup/database provided"
  }

  assert {
    condition     = aws_athena_named_query.cloudwatch_create_table[0].workgroup == "my-workgroup"
    error_message = "Athena create table query workgroup does not match expected value"
  }

  assert {
    condition     = aws_athena_named_query.cloudwatch_create_table[0].database == "my-database"
    error_message = "Athena create table query database does not match expected value"
  }

  assert {
    condition     = aws_athena_named_query.cloudwatch_view_logs[0].workgroup == "my-workgroup"
    error_message = "Athena view logs query workgroup does not match expected value"
  }
}
