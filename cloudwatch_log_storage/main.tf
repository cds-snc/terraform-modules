/* 
* # CloudWatch Log Storage
*
* This module creates an S3 bucket for storing CloudWatch logs, a Kinesis Firehose delivery stream to send the logs to S3, and subscription filters for each specified CloudWatch log group to forward all logs to the delivery stream. This allows for long term storage of logs in a cheaper storage medium than CloudWatch.
* 
* If an Athena workgroup and database is provided, saved Athena queries will also be created that allow you to create a table and query the logs.
*/

#
# S3 bucket for storing CloudWatch logs
#
module "cloudwatch_log_storage" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v11.3.6"
  bucket_name       = "${var.product_name}-cloudwatch-log-storage"
  billing_tag_value = var.billing_tag_value

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id                                     = "remove_noncurrent_versions"
      enabled                                = true
      abort_incomplete_multipart_upload_days = "7"
      noncurrent_version_expiration = {
        days = "30"
      }
    },
    {
      id      = "transition_storage"
      enabled = true
      transition = [
        {
          days          = "60"
          storage_class = "STANDARD_IA"
        },
        {
          days          = "120"
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id      = "expire_logs"
      enabled = true
      expiration = {
        days = var.log_expiration_days
      }
    }
  ]
}

#
# Kinesis Firehose delivery stream to send CloudWatch logs to S3
#
resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_log_storage" {
  name        = "${var.product_name}-cloudwatch-log-storage"
  destination = "extended_s3"

  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_cloudwatch_log_storage.arn
    bucket_arn         = module.cloudwatch_log_storage.s3_bucket_arn
    compression_format = "GZIP"

    dynamic_partitioning_configuration {
      enabled = true
    }

    processing_configuration {
      enabled = true
      processors {
        type = "Decompression"
        parameters {
          parameter_name  = "CompressionFormat"
          parameter_value = "GZIP"
        }
      }
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{logGroup:(.logGroup | ltrimstr(\"/\") | gsub(\"/\"; \"-\"))}"
        }
      }
    }

    buffering_size      = 64
    buffering_interval  = 300
    prefix              = "logs/log_group=!{partitionKeyFromQuery:logGroup}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/!{firehose:error-output-type}/"
  }
}

#
# Create a subscription filter for each CloudWatch log group to send all logs to the Kinesis Firehose delivery stream
#
resource "aws_cloudwatch_log_subscription_filter" "firehose_subscription" {
  for_each = toset(var.cloudwatch_log_group_names)

  name            = "log-storage${replace(replace(each.value, "/", "-"), "_", "-")}"
  log_group_name  = each.value
  role_arn        = aws_iam_role.cloudwatch_log_storage.arn
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_log_storage.arn
  filter_pattern  = "" # Forward all logs
}
