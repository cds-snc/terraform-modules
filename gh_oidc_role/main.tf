/* # gh_oicd_role
* Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
* This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.
*/


data "aws_caller_identity" "current" {}

data "tls_certificate" "thumprint" {
  url = local.gh_url
}

resource "aws_iam_role" "this" {
  count = length(var.roles)


  name               = tolist(var.roles)[count.index].name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[count.index].json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = length(data.aws_iam_policy_document.oidc_assume_role_policy.*)

  source_policy_documents = [
    data.aws_iam_policy_document.oidc_assume_role_policy[count.index].json,
    var.assume_policy,
  ]

}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  count = length(var.roles)

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_exists ? "arn:aws:iam::${data.aws_caller_identity.account_id}:oidc-provider/token.actions.githubusercontent.com" : aws_iam_openid_connect_provider.github[0].arn ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.org_name}/${tolist(var.roles)[count.index].repo_name}:${tolist(var.roles)[count.index].claim}"]

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
