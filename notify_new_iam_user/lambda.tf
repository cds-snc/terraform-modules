/* 
* Automatically notify when a new iam user is added to an aws account 
*
* This module sets up a lambda that will automatically notify of any iam user added in an AWS account.
*/

# Define a lambda permission for the function
resource "aws_lambda_permission" "notify_new_iam_user_added_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_iam_user_added_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.new_iam_user_added_event_rule.arn
}

#
# Lambda: Notify when a new iam user is created 
#
data "archive_file" "notify_new_iam_user_added" {
  type        = "zip"
  source_file = "${path.module}/functions/index.py"
  output_path = "/tmp/notify_new_iam_user_added.zip"
}

# Lambda function that is used to detect a new iam user added 
resource "aws_lambda_function" "new_iam_user_added_lambda" {
  function_name = var.function_name
  description   = "Repsonds to new iam user added"
  role          = aws_iam_role.new_iam_user_response_role.arn
  environment {
    variables = {
      outbound_topic_arn = "arn:aws:sns:${local.region}:${local.account_id}:${var.sns_topic}"
      logging_level      = var.logging_level
    }
  }
  handler = "index.lambda_handler"
  runtime = "python3.9"
  timeout = 60

  filename         = data.archive_file.notify_new_iam_user_added.output_path
  source_code_hash = filebase64sha256(data.archive_file.notify_new_iam_user_added.output_path)

  tracing_config {
    mode = "PassThrough"
  }
  depends_on = [
    aws_iam_role.new_iam_user_response_role
  ]
}
