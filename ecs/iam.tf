################################################################################
# Task execution role: used by ECS to initialize and manage tasks
################################################################################

resource "aws_iam_role" "this_task_exec" {
  count = local.is_create_task_exec_role ? 1 : 0

  name               = "${local.task_definition_family}_ecs_task_exec_role"
  assume_role_policy = data.aws_iam_policy_document.this_task_exec_assume[0].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "this_task_exec_assume" {
  count = local.is_create_task_exec_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "this_task_exec" {
  count = local.is_create_task_exec_role ? 1 : 0

  name   = "${local.task_definition_family}_ecs_task_exec_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.this_task_exec_combined[0].json
  tags   = local.common_tags
}

data "aws_iam_policy_document" "this_task_exec_combined" {
  count = local.is_create_task_exec_role ? 1 : 0

  source_policy_documents = concat([
    data.aws_iam_policy_document.this_task_exec_ecr[0].json,
    data.aws_iam_policy_document.this_task_exec_logs[0].json,
  ], var.task_exec_role_policy_documents)
}


data "aws_iam_policy_document" "this_task_exec_ecr" {
  count = local.is_create_task_exec_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_task_exec_logs" {
  count = local.is_create_task_exec_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "this_task_exec" {
  count = local.is_create_task_exec_role ? 1 : 0

  role       = aws_iam_role.this_task_exec[0].name
  policy_arn = aws_iam_policy.this_task_exec[0].arn
}


################################################################################
# Task role: used at runtime by the app to access AWS resources
################################################################################

resource "aws_iam_role" "this_task" {
  count = local.is_create_task_role ? 1 : 0

  name               = "${local.task_definition_family}_ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.this_task_assume[0].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "this_task_assume" {
  count = local.is_create_task_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "this_task" {
  count = local.is_create_task_role && length(var.task_role_policy_documents) > 0 ? 1 : 0

  name   = "${local.task_definition_family}_ecs_task_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.this_task_combined[0].json
  tags   = local.common_tags
}

data "aws_iam_policy_document" "this_task_combined" {
  count                   = local.is_create_task_role && length(var.task_role_policy_documents) > 0 ? 1 : 0
  source_policy_documents = var.task_role_policy_documents
}

resource "aws_iam_role_policy_attachment" "this_task" {
  count = local.is_create_task_role && length(var.task_role_policy_documents) > 0 ? 1 : 0

  role       = aws_iam_role.this_task[0].name
  policy_arn = aws_iam_policy.this_task[0].arn
}
