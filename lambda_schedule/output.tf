output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "lambda_function_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the Lambda function"
  value       = "/aws/lambda/${module.lambda.function_name}"
}
