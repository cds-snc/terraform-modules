output "ecr_repository_arn" {
  description = "The ARN of the ECR repository for the Lambda image"
  value       = var.create_ecr_repository ? aws_ecr_repository.this[0].arn : ""
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for the Lambda image"
  value       = var.create_ecr_repository ? aws_ecr_repository.this[0].repository_url : ""
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.this_lambda.function_arn
}

output "lambda_function_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the Lambda function"
  value       = "/aws/lambda/${module.this_lambda.function_name}"
}

output "lambda_function_role_arn" {
  description = "The IAM role ARN of the Lambda function"
  value       = module.this_lambda.function_role_arn
}
