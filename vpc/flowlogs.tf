resource "aws_flow_log" "flow_logs" {
  count           = var.enable_flow_log ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_log ? 1 : 0
  # checkov:skip=CKV_AWS_158:Encryption using default CloudWatch service key is acceptable
  name              = "${var.name}_flow_logs"
  retention_in_days = 30
}

resource "aws_iam_role" "flow_logs" {
  count              = var.enable_flow_log ? 1 : 0
  name               = "${var.name}_flow_logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_service_principal[0].json
}

data "aws_iam_policy_document" "vpc_flow_logs_service_principal" {
  count = var.enable_flow_log ? 1 : 0
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "vpc_metrics_flow_logs_write_policy_attach" {
  count      = var.enable_flow_log ? 1 : 0
  role       = aws_iam_role.flow_logs[0].name
  policy_arn = aws_iam_policy.vpc_metrics_flow_logs_write_policy[0].arn
}

resource "aws_iam_policy" "vpc_metrics_flow_logs_write_policy" {
  count       = var.enable_flow_log ? 1 : 0
  name        = "VpcMetricsFlowLogsWrite"
  description = "IAM policy for writing flow logs in CloudWatch"
  path        = "/"
  policy      = data.aws_iam_policy_document.vpc_metrics_flow_logs_write[0].json
}

data "aws_iam_policy_document" "vpc_metrics_flow_logs_write" {

  count = var.enable_flow_log ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = [
      aws_cloudwatch_log_group.flow_logs[0].arn,
      "${aws_cloudwatch_log_group.flow_logs[0].arn}:log-stream:*"
    ]
  }
}
