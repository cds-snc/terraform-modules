
module "vpn" {
  source = "../../"

  endpoint_name   = "vpn"
  access_group_id = "12345678-abcd-1234-efgh-123456789012"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.cidr_block
  subnet_cidr_blocks  = module.vpc.private_subnet_cidr_blocks
  acm_certificate_arn = aws_acm_certificate.self_signed.arn

  billing_tag_value = "Test"
}

#
# VPC that will host the Client VPN endpoint
# Note that this must exist before the client VPN can be created
#
module "vpc" {
  source = "../../../vpc"
  name   = "vpc"

  high_availability = true
  enable_flow_log   = true

  allow_https_request_out          = true
  allow_https_request_out_response = true
  allow_https_request_in           = true
  allow_https_request_in_response  = true

  billing_tag_value = "Test"
}

#
# Generate a self-signed certificate for the Client VPN endpoint
# Alternatively, you can use https://github.com/OpenVPN/easy-rsa to generate the certificate
#
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  private_key_pem       = tls_private_key.this.private_key_pem
  validity_period_hours = 43800 # 5 years
  early_renewal_hours   = 168   # Generate new cert if Terraform is run within 1 week of expiry

  subject {
    common_name = "vpn.digital.canada.ca"
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

resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.this.private_key_pem
  certificate_body = tls_self_signed_cert.this.cert_pem
}
