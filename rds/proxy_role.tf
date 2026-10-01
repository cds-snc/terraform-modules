resource "aws_iam_role" "rds_proxy" {
  count = var.use_proxy ? 1 : 0

  name               = "${var.name}_rds_proxy"
  tags               = merge(local.common_tags, local.cbrid_tags)
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "assume_role" {
  count = var.use_proxy ? 1 : 0

  statement {
    sid     = "RDSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "read_connection_string" {
  count = local.use_proxy_secret_auth ? 1 : 0

  statement {
    sid    = 0
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = concat([aws_secretsmanager_secret.connection_string[0].arn], var.proxy_secret_auth_arns)
  }
  statement {
    sid       = 1
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
  statement {
    sid       = 2
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.${local.region}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "read_connection_string" {
  count = local.use_proxy_secret_auth ? 1 : 0

  name   = "${var.name}ReadConnectionString"
  path   = "/"
  policy = data.aws_iam_policy_document.read_connection_string[0].json
  tags   = merge(local.common_tags, local.cbrid_tags)
}

resource "aws_iam_role_policy_attachment" "read_connection_string" {
  count = local.use_proxy_secret_auth ? 1 : 0

  role       = aws_iam_role.rds_proxy[0].name
  policy_arn = aws_iam_policy.read_connection_string[0].arn
}

data "aws_iam_policy_document" "proxy_iam_database_connect" {
  count = local.use_proxy_iam_authentication ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["rds-db:connect"]
    resources = [
      for database_username in keys(local.proxy_iam_authentication_users) :
      "${local.rds_db_resource_arn_prefix}:dbuser:${aws_rds_cluster.cluster.cluster_resource_id}/${database_username}"
    ]
  }
}

resource "aws_iam_policy" "proxy_iam_database_connect" {
  count = local.use_proxy_iam_authentication ? 1 : 0

  name   = "${var.name}RdsProxyIamDatabaseConnect"
  path   = "/"
  policy = data.aws_iam_policy_document.proxy_iam_database_connect[0].json
  tags   = merge(local.common_tags, local.cbrid_tags)
}

resource "aws_iam_role_policy_attachment" "proxy_iam_database_connect" {
  count = local.use_proxy_iam_authentication ? 1 : 0

  role       = aws_iam_role.rds_proxy[0].name
  policy_arn = aws_iam_policy.proxy_iam_database_connect[0].arn
}

data "aws_iam_policy_document" "task_iam_database_connect" {
  for_each = local.proxy_iam_authentication_users

  statement {
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["${local.rds_db_resource_arn_prefix}:dbuser:${local.proxy_resource_id}/${each.key}"]
  }
}

resource "aws_iam_policy" "task_iam_database_connect" {
  for_each = local.proxy_iam_authentication_users

  name   = "${var.name}RdsProxyIamDatabaseConnect${each.key}"
  path   = "/"
  policy = data.aws_iam_policy_document.task_iam_database_connect[each.key].json
  tags   = merge(local.common_tags, local.cbrid_tags)
}

resource "aws_iam_role_policy_attachment" "task_iam_database_connect" {
  for_each = local.proxy_iam_authentication_task_roles

  role       = each.value.task_role_name
  policy_arn = aws_iam_policy.task_iam_database_connect[each.value.database_username].arn
}
