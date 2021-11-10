
locals {
  use_vpc = (length(var.vpc.subnet_ids) > 0 && length(var.vpc.security_group_ids) > 0)
}

### Policies needed if not on VPN

data "aws_iam_policy_document" "non_vpc_policies" {

  count = local.use_vpc ? 0 : 1
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ECRImageAccess"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForlayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      var.ecr_arn
    ]
  }
}

resource "aws_iam_policy" "non_vpc_policies" {
  count  = local.use_vpc ? 0 : 1
  name   = "${var.name}_non_vpc"
  path   = "/"
  policy = data.aws_iam_policy_document.non_vpc_policies[0].json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "non_vpc_policies" {
  count      = local.use_vpc ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.non_vpc_policies[0].arn
}


### Policies needed if on VPC

data "aws_iam_policy_document" "vpc_policies" {

  count = local.use_vpc ? 1 : 0

  statement {
    sid    = "ECRImageAccess"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForlayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      var.ecr_arn
    ]
  }
}

resource "aws_iam_policy" "vpc_policies" {
  count  = local.use_vpc ? 1 : 0
  name   = "${var.name}_vpc"
  path   = "/"
  policy = data.aws_iam_policy_document.vpc_policies[0].json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "vpc_policies" {
  count      = local.use_vpc ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.vpc_policies[0].arn
}

# Use AWS managed IAM policy
####
# Provides minimum permissions for a Lambda function to execute while
# accessing a resource within a VPC - create, describe, delete network
# interfaces and write permissions to CloudWatch Logs.
####
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  count      = local.use_vpc ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}