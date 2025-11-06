data "aws_iam_policy_document" "service_principal" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "combined_assume_role" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.service_principal.json],
    var.assume_role_policies
  )
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.combined_assume_role.json
  tags               = local.common_tags
}
