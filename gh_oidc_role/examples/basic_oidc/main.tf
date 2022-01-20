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
}

data "aws_iam_policy" "admin" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = local.readonly_role
  policy_arn = data.aws_iam_policy.admin.arn
  depends_on = [module.gh_oidc_roles]
}
