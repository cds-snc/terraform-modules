data "aws_iam_policy_document" "service_principal" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

output "service_principal_assume" {
  value = data.aws_iam_policy_document.service_principal.json
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
