resource "aws_iam_role" "this" {
  name               = "CodeBuildRunner-${var.project_name}"
  assume_role_policy = data.aws_iam_policy_document.this_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }

  dynamic "statement" {
    for_each = local.is_vpc_config ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = local.is_vpc_config ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["ec2:CreateNetworkInterfacePermission"]
      resources = ["arn:aws:ec2:${local.region}:${local.account_id}:network-interface/*"]

      condition {
        test     = "StringEquals"
        variable = "ec2:AuthorizedService"
        values   = ["codebuild.amazonaws.com"]
      }

      condition {
        test     = "ArnEquals"
        variable = "ec2:Subnet"
        values = [
          for subnet_id in var.subnet_ids :
          "arn:aws:ec2:${local.region}:${local.account_id}:subnet/${subnet_id}"
        ]
      }
    }
  }
}
