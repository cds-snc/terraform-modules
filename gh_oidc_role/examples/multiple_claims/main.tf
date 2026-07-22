locals {
  multi_claim_role = "GHOIDCMultiClaimRole"
}

# This example shows how to allow a single role to be assumed from more than one
# org by supplying the `claims` list instead of the single `repo_name`/`claim`
# pair. The resulting assume-role policy will contain multiple `sub` values:
#
#   "token.actions.githubusercontent.com:sub": [
#     "repo:cds-snc/*:ref:refs/heads/main",
#     "repo:cds-snc@11111111/*:ref:refs/heads/main"
#   ]
module "gh_oidc_roles" {
  source            = "../../"
  billing_tag_value = "terratest"
  roles = [
    {
      name = local.multi_claim_role
      claims = [
        {
          repo_name = "*" # Allow any repo in the default org (cds-snc)
          claim     = "ref:refs/heads/main"
        },
        {
          repo_name = "*"
          claim     = "ref:refs/heads/main"
          org_name  = "cds-snc@11111111" # Override the org for this entry
        }
      ]
    }
  ]
}

data "aws_iam_policy" "read_only" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "read_only" {
  role       = local.multi_claim_role
  policy_arn = data.aws_iam_policy.read_only.arn
  depends_on = [module.gh_oidc_roles]
}
