locals {
  test_role_name = "terraform-modules-test"
}

module "test_role" {
  source            = "github.com/cds-snc/terraform-modules//gh_oidc_role?ref=v9.6.8"
  billing_tag_value = var.billing_code
  roles = [
    {
      name      = local.test_role_name
      repo_name = "terraform-modules"
      claim     = "pull_request"
    }
  ]
}

resource "aws_iam_role_policy_attachment" "test_role" {
  role       = local.test_role_name
  policy_arn = data.aws_iam_policy.administrator_access.arn
  depends_on = [
    module.test_role
  ]
}

data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}
