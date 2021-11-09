resource "aws_lambda_permission" "api_gateway" {
  count         = var.allow_api_gateway_invoke ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gateway_source_arn
}

resource "aws_lambda_permission" "s3_execution" {
  count         = var.allow_s3_execution ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}

resource "aws_s3_bucket_notification" "this" {
  count  = var.allow_s3_execution ? 1 : 0
  bucket = var.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.s3_execution]
}

resource "aws_lambda_permission" "sns" {
  count = length(var.sns_topic_arns)

  statement_id  = "AllowExecutionFromSNS-${var.sns_topic_arns[count.index]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arns[count.index]
}
