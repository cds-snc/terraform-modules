
resource "aws_s3_bucket_notification" "api-notification" {
  count  = var.allow_s3_execution ? 1 : 0
  bucket = var.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.api-permission-s3]
}