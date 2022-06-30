output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_role_arn" {
  description = "ARN of the Lambda function execution role."
  value       = aws_iam_role.this.arn
}

output "invoke_arn" {
  description = "ARN used to invoke the Lambda function."
  value       = aws_lambda_function.this.invoke_arn
}
