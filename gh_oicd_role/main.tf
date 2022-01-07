/* # gh_oicd_role
* Creates an OpenID Connect Role that can be used for authenticating workflows in Github Actions
* This allows for a more secure way to connect to AWS as it doesn't rely on static credentials but uses temporary credentials created for each run.
*/


data "aws_caller_identity" "current" {}

data "tls_certificate" "thumprint" {
  url = local.gh_url
}

resource "aws_iam_role" "this" {
  name               = "gh-oicd-aws"
  assume_role_policy = data.aws_iam_policy_document.asume_role_saml.json
}

data "aws_iam_policy_document" "asume_role_saml" {
  statement {
    principal {
      type        = "Federated"
      identifiers = ["arn:aws_iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.gh_path}"]
    }
  }
  actions = ["sts:AssumeRoleWithWebIdentity"]
  condition {
    test     = "ForAnyValue:StringLike"
    variable = "vstoken.actions.githubusercontent.com:sub"
    values   = "repo:<owner>/<repo>:*"
  }

}

resource "aws_iam_openid_connect_provider" "default" {
  url             = local.gh_url
  client_id_list  = local.audiences
  thumbprint_list = [data.tls_certificate.thumprint.certificates.0.sha1_fingerprint]
}
