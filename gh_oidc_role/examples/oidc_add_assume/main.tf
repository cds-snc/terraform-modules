locals {
  readonly_role = "GHOIDCReadOnlyRole"
}

module "gh_oidc_roles" {
  source            = "../../"
  billing_tag_value = "terratest"
  roles = [
    {
      name      = local.readonly_role
      repo_name = "terraform-modules"
      claim     = "ref:refs/heads/main"
    }
  ]
  assume_policy = data.aws_iam_policy_document.service_principal.json
}

data "aws_iam_policy" "read_only" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "read_only" {
  role       = local.readonly_role
  policy_arn = data.aws_iam_policy.read_only.arn
  depends_on = [module.gh_oidc_roles]
}

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
