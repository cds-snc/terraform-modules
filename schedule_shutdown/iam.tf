resource "aws_iam_role" "schedule" {
  name               = "${local.lambda_name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "schedule" {
  name   = "${local.lambda_name}-lambda"
  path   = "/"
  policy = data.aws_iam_policy_document.combined.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "schedule" {
  role       = aws_iam_role.schedule.name
  policy_arn = aws_iam_policy.schedule.arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = concat([
    data.aws_iam_policy_document.cloudwatch_policy.json,
    local.is_cloudwatch_alarm_arns ? data.aws_iam_policy_document.cloudwatch_alarm_policy[0].json : "",
    local.is_ecs_arns ? data.aws_iam_policy_document.ecs_service_policy[0].json : "",
    local.is_rds_arns ? data.aws_iam_policy_document.rds_cluster_policy[0].json : "",
    local.is_route53_healthcheck_arns ? data.aws_iam_policy_document.route53_healthcheck_policy[0].json : "",
  ])
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.schedule.arn}:*",
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch_alarm_policy" {
  count = local.is_cloudwatch_alarm_arns ? 1 : 0

  statement {
    sid    = "EnableDisableCloudWatchAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
    ]
    resources = var.cloudwatch_alarm_arns
  }
}

data "aws_iam_policy_document" "ecs_service_policy" {
  count = local.is_ecs_arns ? 1 : 0

  statement {
    sid    = "UpdateECSServices"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
    ]
    resources = var.ecs_service_arns
  }
}

data "aws_iam_policy_document" "rds_cluster_policy" {
  count = local.is_rds_arns ? 1 : 0

  statement {
    sid    = "StartStopRDSClusters"
    effect = "Allow"
    actions = [
      "rds:StartDBCluster",
      "rds:StopDBCluster",
    ]
    resources = var.rds_cluster_arns
  }
}

data "aws_iam_policy_document" "route53_healthcheck_policy" {
  count = local.is_route53_healthcheck_arns ? 1 : 0

  statement {
    sid    = "EnableDisableRotue53HealthChecks"
    effect = "Allow"
    actions = [
      "route53:UpdateHealthCheck",
    ]
    resources = var.route53_healthcheck_arns
  }
}