
module "vpn" {
  source = "../../"

  endpoint_name   = "vpn"
  access_group_id = "12345678-abcd-1234-efgh-123456789012"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.cidr_block
  subnet_cidr_blocks  = module.vpc.private_subnet_cidr_blocks
  acm_certificate_arn = aws_acm_certificate.self_signed.arn

  client_vpn_saml_metadata_document              = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48bWQ6RW50aXR5RGVzY3JpcHRvciB4bWxuczptZD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOm1ldGFkYXRhIiBlbnRpdHlJRD0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiI+CiAgPG1kOklEUFNTT0Rlc2NyaXB0b3IgV2FudEF1dGhuUmVxdWVzdHNTaWduZWQ9ImZhbHNlIiBwcm90b2NvbFN1cHBvcnRFbnVtZXJhdGlvbj0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4KICAgIDxtZDpLZXlEZXNjcmlwdG9yIHVzZT0ic2lnbmluZyI+CiAgICAgIDxkczpLZXlJbmZvIHhtbG5zOmRzPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj4KICAgICAgICA8ZHM6WDUwOURhdGE+CiAgICAgICAgICA8ZHM6WDUwOUNlcnRpZmljYXRlPmFiY2RlZjwvZHM6WDUwOUNlcnRpZmljYXRlPgogICAgICAgIDwvZHM6WDUwOURhdGE+CiAgICAgIDwvZHM6S2V5SW5mbz4KICAgIDwvbWQ6S2V5RGVzY3JpcHRvcj4KICAgIDxtZDpTaW5nbGVMb2dvdXRTZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVBPU1QiIExvY2F0aW9uPSJodHRwczovL3BvcnRhbC5zc28uY2EtY2VudHJhbC0xLmFtYXpvbmF3cy5jb20vc2FtbC9sb2dvdXQvYWJjZGVmIi8+CiAgICA8bWQ6U2luZ2xlTG9nb3V0U2VydmljZSBCaW5kaW5nPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YmluZGluZ3M6SFRUUC1SZWRpcmVjdCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2xvZ291dC9hYmNkZWYiLz4KICAgIDxtZDpOYW1lSURGb3JtYXQvPgogICAgPG1kOlNpbmdsZVNpZ25PblNlcnZpY2UgQmluZGluZz0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmJpbmRpbmdzOkhUVFAtUE9TVCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2Fzc2VydGlvbi9hYmNkZWYiLz4KICAgIDxtZDpTaW5nbGVTaWduT25TZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVJlZGlyZWN0IiBMb2NhdGlvbj0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiIvPgogIDwvbWQ6SURQU1NPRGVzY3JpcHRvcj4KPC9tZDpFbnRpdHlEZXNjcmlwdG9yPgo="
  client_vpn_self_service_saml_metadata_document = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48bWQ6RW50aXR5RGVzY3JpcHRvciB4bWxuczptZD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOm1ldGFkYXRhIiBlbnRpdHlJRD0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiI+CiAgPG1kOklEUFNTT0Rlc2NyaXB0b3IgV2FudEF1dGhuUmVxdWVzdHNTaWduZWQ9ImZhbHNlIiBwcm90b2NvbFN1cHBvcnRFbnVtZXJhdGlvbj0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4KICAgIDxtZDpLZXlEZXNjcmlwdG9yIHVzZT0ic2lnbmluZyI+CiAgICAgIDxkczpLZXlJbmZvIHhtbG5zOmRzPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj4KICAgICAgICA8ZHM6WDUwOURhdGE+CiAgICAgICAgICA8ZHM6WDUwOUNlcnRpZmljYXRlPmFiY2RlZjwvZHM6WDUwOUNlcnRpZmljYXRlPgogICAgICAgIDwvZHM6WDUwOURhdGE+CiAgICAgIDwvZHM6S2V5SW5mbz4KICAgIDwvbWQ6S2V5RGVzY3JpcHRvcj4KICAgIDxtZDpTaW5nbGVMb2dvdXRTZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVBPU1QiIExvY2F0aW9uPSJodHRwczovL3BvcnRhbC5zc28uY2EtY2VudHJhbC0xLmFtYXpvbmF3cy5jb20vc2FtbC9sb2dvdXQvYWJjZGVmIi8+CiAgICA8bWQ6U2luZ2xlTG9nb3V0U2VydmljZSBCaW5kaW5nPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YmluZGluZ3M6SFRUUC1SZWRpcmVjdCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2xvZ291dC9hYmNkZWYiLz4KICAgIDxtZDpOYW1lSURGb3JtYXQvPgogICAgPG1kOlNpbmdsZVNpZ25PblNlcnZpY2UgQmluZGluZz0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmJpbmRpbmdzOkhUVFAtUE9TVCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2Fzc2VydGlvbi9hYmNkZWYiLz4KICAgIDxtZDpTaW5nbGVTaWduT25TZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVJlZGlyZWN0IiBMb2NhdGlvbj0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiIvPgogIDwvbWQ6SURQU1NPRGVzY3JpcHRvcj4KPC9tZDpFbnRpdHlEZXNjcmlwdG9yPgo="

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
