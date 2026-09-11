output "lambda_arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.sentinel_forwarder.arn
}

output "lambda_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.sentinel_forwarder.function_name
}

# Names which API path this forwarder is on, and is the one way to see that
# from a plan: the Lambda's own environment attribute reads as wholly unknown
# whenever it carries the SSM parameter ARN, so a v2 variable leaking onto a v1
# forwarder is otherwise invisible until apply. Keys only — the values include
# configuration that is noisy rather than secret.
output "lambda_environment_keys" {
  description = "Sorted names of the environment variables set on the Lambda. `DCE_ENDPOINT` and `DCR_CONFIG` appearing here means this forwarder is on the Logs Ingestion API."
  value       = sort(keys(local.lambda_environment))
}
