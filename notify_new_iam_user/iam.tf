#
# IAM roles and policies
#

# get the aws partition
data "aws_partition" "current" {}

# IAM Role for Lambda Function
resource "aws_iam_role" "new_iam_user_response_role" {
  name                = "new_iam_user_response_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for Lambda Function
resource "aws_iam_role_policy" "new_iam_user_response_policy" {
  name = "new_iam_user_response_policy"
  role = aws_iam_role.new_iam_user_response_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsPermissions"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Sid      = "AllowSnsActions"
        Resource = "arn:aws:sns:ca-central-1:${local.account_id}:internal-sre-alert"
      }
    ]
  })
}
