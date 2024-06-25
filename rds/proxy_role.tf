resource "aws_iam_role" "rds_proxy" {
  name               = "${var.name}_rds_proxy"
  tags               = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
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
  statement {
    sid    = 0
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = concat([aws_secretsmanager_secret.connection_string.arn], var.proxy_secret_auth_arns)
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
  name   = "${var.name}ReadConnectionString"
  path   = "/"
  policy = data.aws_iam_policy_document.read_connection_string.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "read_connection_string" {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = aws_iam_policy.read_connection_string.arn
}
