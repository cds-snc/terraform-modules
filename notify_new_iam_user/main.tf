/* 
* Automatically notify when a new iam user is added to an aws account 
*
* This module sets up a lambda that will automatically notify of any iam user added in an AWS account.
*/

# Get the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Lambda: Notify when a new iam user is created 
#
data "archive_file" "notify_new_iam_user_added" {
  type        = "zip"
  source_file = "${path.module}/functions/index.py"
  output_path = "/tmp/notify_new_iam_user_added.zip"
}

# Lambda function that is used to detect a new iam user added 
resource "aws_lambda_function" "new_iam_user_added" {
  function_name = var.function_name
  description   = "Repsonds to new iam user added"
  role          = new_iam_user_response_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  filename         = data.archive_file.index.output_path
  source_code_hash = filebase64sha256(data.archive_file.index.output_path)

  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      sns_topic_arn = "arn:aws:sns:${local.region}:${local.account_id}:internal-sre-alert"
    }
  }
  depends_on = [
    aws_iam_rolenew_iam_user_response_role
  ]
}


# Permission to execute the Lambda function
resource "aws_lambda_permission" "new_iam_user_added_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_iam_user_added.arn
  principal = "events.amazonaws.com"
}
