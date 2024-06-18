#
# SAML identify providers that are used to authenticate users to the Client VPN endpoint.
# The metadata documents are from apps created in the IAM Identity Center.
#
resource "aws_iam_saml_provider" "client_vpn" {
  count                  = var.authentication_option == "federated-authentication" ? 1 : 0
  name                   = "client-vpn"
  saml_metadata_document = base64decode(var.client_vpn_saml_metadata_document)
  tags                   = local.common_tags
}

resource "aws_iam_saml_provider" "client_vpn_self_service" {
  count                  = local.is_self_service && var.authentication_option == "federated-authentication" ? 1 : 0
  name                   = "client-vpn-self-service"
  saml_metadata_document = base64decode(var.client_vpn_self_service_saml_metadata_document)
  tags                   = local.common_tags
}
