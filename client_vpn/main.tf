/* 
* # Client VPN
* Create a Client VPN endpoint in the specified VPC's subnets.  This can be used to provide secure access to private resources in the VPC.
*
* Client authentication and authorization is managed by AWS IAM Identity Center.  Users must be added to the access group specified by the `access_group_id` variable in order to connect to the VPN.
*
* The client VPN endpoint must be associated with the resource's subnet that you are providing access to.  For each association, there is a fixed $0.10/hour charge as well as a $0.05/hour charge for each active client connection.
*
* ## Credit
* This module is based on the design of [fivexl/terraform-aws-client-vpn-endpoint](https://github.com/fivexl/terraform-aws-client-vpn-endpoint).
*/

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.endpoint_name
  vpc_id                 = var.vpc_id
  server_certificate_arn = var.acm_certificate_arn
  client_cidr_block      = var.endpoint_cidr_block
  self_service_portal    = var.self_service_portal

  session_timeout_hours = var.session_timeout_hours
  split_tunnel          = var.split_tunnel
  transport_protocol    = var.transport_protocol
  security_group_ids    = [aws_security_group.this.id]
  dns_servers           = concat([local.dns_host], var.public_dns_servers)

  dynamic "authentication_options" {
    for_each = var.authentication_option == "federated-authentication" ? [1] : []
    content {
      type                           = "federated-authentication"
      saml_provider_arn              = aws_iam_saml_provider.client_vpn[0].arn
      self_service_saml_provider_arn = local.is_self_service ? aws_iam_saml_provider.client_vpn_self_service[0].arn : null
    }
  }

  dynamic "authentication_options" {
    for_each = var.authentication_option == "certificate-authentication" ? [1] : []
    content {
      type                       = "certificate-authentication"
      root_certificate_chain_arn = aws_acm_certificate.client_vpn[0].arn
    }
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  }

  client_login_banner_options {
    enabled     = true
    banner_text = var.banner_text
  }

  tags = local.common_tags
}

#
# Associate subnets and authorize access
#
resource "aws_ec2_client_vpn_network_association" "this_subnets" {
  for_each               = toset(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this_internal_dns" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = "${local.dns_host}/32"
  authorize_all_groups   = true
  description            = "Authorization for ${var.endpoint_name} to DNS"
}


resource "aws_ec2_client_vpn_authorization_rule" "this_subnets_certificate" {
  for_each               = var.authentication_option == "federated-authentication" ? [] : toset(var.subnet_cidr_blocks)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
  description            = "Rule name: ${each.value}"
}

# Keeping the name this_subnets so that the resources don't have to be moved/recreated for existing installations
resource "aws_ec2_client_vpn_authorization_rule" "this_subnets" {
  for_each               = var.authentication_option == "federated-authentication" ? toset(var.subnet_cidr_blocks) : []
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value
  access_group_id        = var.access_group_id
  description            = "Rule name: ${each.value}"
}

#
# VPN security group
#
resource "aws_security_group" "this" {
  name        = "client-vpn-endpoint-${var.endpoint_name}"
  description = "Egress All. Used to allow access to other security groups."
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

#
# Connection logging
#
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/client-vpn-endpoint/${var.endpoint_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

#
# Certificate based auth
#

resource "tls_private_key" "client_vpn" {
  count     = var.authentication_option == "certificate-authentication" ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "client_vpn" {
  count                 = var.authentication_option == "certificate-authentication" ? 1 : 0
  private_key_pem       = tls_private_key.client_vpn[0].private_key_pem
  validity_period_hours = var.certificate_validity_period
  early_renewal_hours   = var.certificate_early_renewal_period

  subject {
    common_name  = var.common_name
    organization = var.organization
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "ipsec_end_system",
    "ipsec_tunnel",
    "any_extended",
    "cert_signing",
  ]
}

resource "aws_acm_certificate" "client_vpn" {
  count            = var.authentication_option == "certificate-authentication" ? 1 : 0
  private_key      = tls_private_key.client_vpn[0].private_key_pem
  certificate_body = tls_self_signed_cert.client_vpn[0].cert_pem
}
