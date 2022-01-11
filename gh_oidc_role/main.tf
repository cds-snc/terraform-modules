/* # gh_oicd_role
* Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
* This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.
*/


data "aws_caller_identity" "current" {}

data "tls_certificate" "thumprint" {
  url = local.gh_url
}

resource "aws_iam_role" "this" {
  for_each = { for r in var.roles : r.name => r }

  name = each.value.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = {
      Effect = "Allow"
      Action = ["sts:AssumeRoleWithWebIdentity"]
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.org_name}/${each.value.repo_name}:${each.value.claim}"
        }
      }

    }
  })
  tags = local.common_tags
}


resource "aws_iam_openid_connect_provider" "github" {
  url             = local.gh_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.thumprint.certificates.0.sha1_fingerprint]
  tags            = local.common_tags
}
