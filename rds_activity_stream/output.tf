output "decrypt_lambda_arn" {
  description = "The ARN of the decrypt Lambda function."
  value       = aws_lambda_function.decrypt.arn
}

output "decrypt_lambda_cloudwatch_log_group_name" {
  description = "The name of the decrypt Lambda function's CloudWatch log group."
  value       = aws_cloudwatch_log_group.decrypt.name
}

output "decrypt_lambda_name" {
  description = "The name of the decrypt Lambda function."
  value       = aws_lambda_function.decrypt.function_name
}

output "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose that is processing the RDS activity stream events."
  value       = aws_kinesis_firehose_delivery_stream.activity_stream.arn
}

output "s3_activity_stream_bucket_arn" {
  description = "The ARN of the S3 bucket that the decrypted activity stream logs are written to."
  value       = module.activity_stream_bucket.s3_bucket_arn
}

output "s3_activity_stream_bucket_name" {
  description = "The name of the S3 bucket that the decrypted activity stream logs are written to."
  value       = module.activity_stream_bucket.s3_bucket_id
}

output "rds_activity_stream_arn" {
  description = "The ARN of the RDS activity stream."
  value       = local.database_kinesis_stream_arn
}
