/* 
* # gh_oicd_role
* Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
* This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.
* 
*/

locals {
  roles_kv = { for r in var.roles : r.name => r }
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "thumprint" {
  url = local.gh_url
}

resource "aws_iam_role" "this" {
  for_each = local.roles_kv


  name               = each.value.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[each.key].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  for_each = data.aws_iam_policy_document.oidc_assume_role_policy

  source_policy_documents = [
    each.value.json,
    var.assume_policy,
  ]

}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  for_each = local.roles_kv

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_exists ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com" : aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.org_name}/${each.value.repo_name}:${each.value.claim}"]

    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.oidc_exists ? 0 : 1
  url             = local.gh_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.thumprint.certificates.0.sha1_fingerprint]
  tags            = local.common_tags
}
