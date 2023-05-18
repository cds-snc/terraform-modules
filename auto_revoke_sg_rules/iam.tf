# IAM Role for Lambda Function
resource "aws_iam_role" "group_change_auto_response_role" {
  name                = "group_change_auto_response_role"
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
resource "aws_iam_role_policy" "security_group_modification" {
  name = "security_group_modification"
  role = aws_iam_role.group_change_auto_response_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RevokeSecurityGroupIngress"
        ]
        Effect   = "Allow"
        Sid      = "AllowSecurityGroupActions"
        Resource = "*"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Sid      = "AllowSnsActions"
        Resource = "arn:aws:sns:${local.region}:${local.account_id}:${var.sns_topic}"
      }
    ]
  })
}
