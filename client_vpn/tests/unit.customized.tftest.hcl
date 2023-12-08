provider "aws" {
  region = "ca-central-1"
}

variables {
  endpoint_name                                  = "vpn"
  access_group_id                                = "12345678-abcd-1234-efgh-123456789012"
  banner_text                                    = "I like private networks"
  endpoint_cidr_block                            = "192.168.0.0/24"
  session_timeout_hours                          = 12
  split_tunnel                                   = false
  transport_protocol                             = "tcp"
  vpc_id                                         = "vpc-12345678"
  vpc_cidr_block                                 = "10.0.0.0/16"
  self_service_portal                            = "enabled"
  public_dns_servers                             = ["1.1.1.1", "8.8.8.8"]
  subnet_ids                                     = ["subnet-12345678", "subnet-87654321"]
  subnet_cidr_blocks                             = ["10.0.0.0/24", "10.1.0.0/24"]
  acm_certificate_arn                            = "arn:aws:acm:ca-central-1:123456789012:certificate/12345678-abcd-1234-efgh-123456789012"
  client_vpn_saml_metadata_document              = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48bWQ6RW50aXR5RGVzY3JpcHRvciB4bWxuczptZD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOm1ldGFkYXRhIiBlbnRpdHlJRD0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiI+CiAgPG1kOklEUFNTT0Rlc2NyaXB0b3IgV2FudEF1dGhuUmVxdWVzdHNTaWduZWQ9ImZhbHNlIiBwcm90b2NvbFN1cHBvcnRFbnVtZXJhdGlvbj0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4KICAgIDxtZDpLZXlEZXNjcmlwdG9yIHVzZT0ic2lnbmluZyI+CiAgICAgIDxkczpLZXlJbmZvIHhtbG5zOmRzPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj4KICAgICAgICA8ZHM6WDUwOURhdGE+CiAgICAgICAgICA8ZHM6WDUwOUNlcnRpZmljYXRlPmFiY2RlZjwvZHM6WDUwOUNlcnRpZmljYXRlPgogICAgICAgIDwvZHM6WDUwOURhdGE+CiAgICAgIDwvZHM6S2V5SW5mbz4KICAgIDwvbWQ6S2V5RGVzY3JpcHRvcj4KICAgIDxtZDpTaW5nbGVMb2dvdXRTZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVBPU1QiIExvY2F0aW9uPSJodHRwczovL3BvcnRhbC5zc28uY2EtY2VudHJhbC0xLmFtYXpvbmF3cy5jb20vc2FtbC9sb2dvdXQvYWJjZGVmIi8+CiAgICA8bWQ6U2luZ2xlTG9nb3V0U2VydmljZSBCaW5kaW5nPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YmluZGluZ3M6SFRUUC1SZWRpcmVjdCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2xvZ291dC9hYmNkZWYiLz4KICAgIDxtZDpOYW1lSURGb3JtYXQvPgogICAgPG1kOlNpbmdsZVNpZ25PblNlcnZpY2UgQmluZGluZz0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmJpbmRpbmdzOkhUVFAtUE9TVCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2Fzc2VydGlvbi9hYmNkZWYiLz4KICAgIDxtZDpTaW5nbGVTaWduT25TZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVJlZGlyZWN0IiBMb2NhdGlvbj0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiIvPgogIDwvbWQ6SURQU1NPRGVzY3JpcHRvcj4KPC9tZDpFbnRpdHlEZXNjcmlwdG9yPgo="
  client_vpn_self_service_saml_metadata_document = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48bWQ6RW50aXR5RGVzY3JpcHRvciB4bWxuczptZD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOm1ldGFkYXRhIiBlbnRpdHlJRD0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiI+CiAgPG1kOklEUFNTT0Rlc2NyaXB0b3IgV2FudEF1dGhuUmVxdWVzdHNTaWduZWQ9ImZhbHNlIiBwcm90b2NvbFN1cHBvcnRFbnVtZXJhdGlvbj0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4KICAgIDxtZDpLZXlEZXNjcmlwdG9yIHVzZT0ic2lnbmluZyI+CiAgICAgIDxkczpLZXlJbmZvIHhtbG5zOmRzPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj4KICAgICAgICA8ZHM6WDUwOURhdGE+CiAgICAgICAgICA8ZHM6WDUwOUNlcnRpZmljYXRlPmFiY2RlZjwvZHM6WDUwOUNlcnRpZmljYXRlPgogICAgICAgIDwvZHM6WDUwOURhdGE+CiAgICAgIDwvZHM6S2V5SW5mbz4KICAgIDwvbWQ6S2V5RGVzY3JpcHRvcj4KICAgIDxtZDpTaW5nbGVMb2dvdXRTZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVBPU1QiIExvY2F0aW9uPSJodHRwczovL3BvcnRhbC5zc28uY2EtY2VudHJhbC0xLmFtYXpvbmF3cy5jb20vc2FtbC9sb2dvdXQvYWJjZGVmIi8+CiAgICA8bWQ6U2luZ2xlTG9nb3V0U2VydmljZSBCaW5kaW5nPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YmluZGluZ3M6SFRUUC1SZWRpcmVjdCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2xvZ291dC9hYmNkZWYiLz4KICAgIDxtZDpOYW1lSURGb3JtYXQvPgogICAgPG1kOlNpbmdsZVNpZ25PblNlcnZpY2UgQmluZGluZz0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmJpbmRpbmdzOkhUVFAtUE9TVCIgTG9jYXRpb249Imh0dHBzOi8vcG9ydGFsLnNzby5jYS1jZW50cmFsLTEuYW1hem9uYXdzLmNvbS9zYW1sL2Fzc2VydGlvbi9hYmNkZWYiLz4KICAgIDxtZDpTaW5nbGVTaWduT25TZXJ2aWNlIEJpbmRpbmc9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpiaW5kaW5nczpIVFRQLVJlZGlyZWN0IiBMb2NhdGlvbj0iaHR0cHM6Ly9wb3J0YWwuc3NvLmNhLWNlbnRyYWwtMS5hbWF6b25hd3MuY29tL3NhbWwvYXNzZXJ0aW9uL2FiY2RlZiIvPgogIDwvbWQ6SURQU1NPRGVzY3JpcHRvcj4KPC9tZDpFbnRpdHlEZXNjcmlwdG9yPgo="
}

run "customized" {
  command = plan

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.client_cidr_block == "192.168.0.0/24"
    error_message = "aws_ec2_client_vpn_endpoint.this.client_cidr_block did not match expected value"
  }

  assert {
    condition     = strcontains(aws_iam_saml_provider.client_vpn_self_service[0].saml_metadata_document, "https://portal.sso.ca-central-1.amazonaws.com/saml/logout/abcdef")
    error_message = "aws_iam_saml_provider.client_vpn_self_service.saml_metadata_document did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.session_timeout_hours == 12
    error_message = "aws_ec2_client_vpn_endpoint.this.session_timeout_hours did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.self_service_portal == "enabled"
    error_message = "aws_ec2_client_vpn_endpoint.this.self_service_portal did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.split_tunnel == false
    error_message = "aws_ec2_client_vpn_endpoint.this.split_tunnel did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.transport_protocol == "tcp"
    error_message = "aws_ec2_client_vpn_endpoint.this.transport_protocol did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.dns_servers[0] == "10.0.0.2"
    error_message = "aws_ec2_client_vpn_endpoint.this.dns_servers[0] did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.dns_servers[1] == "1.1.1.1"
    error_message = "aws_ec2_client_vpn_endpoint.this.dns_servers[1] did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.dns_servers[2] == "8.8.8.8"
    error_message = "aws_ec2_client_vpn_endpoint.this.dns_servers[2] did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.client_login_banner_options[0].banner_text == "I like private networks"
    error_message = "aws_ec2_client_vpn_endpoint.this.client_login_banner_options[0].banner_text did not match expected value"
  }

  assert {
    condition     = length(aws_ec2_client_vpn_network_association.this_subnets) == 2
    error_message = "length(aws_ec2_client_vpn_network_association.this_subnets) did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_network_association.this_subnets["subnet-12345678"].subnet_id == "subnet-12345678"
    error_message = "aws_ec2_client_vpn_network_association.this_subnets['subnet-12345678'].subnet_id did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_network_association.this_subnets["subnet-87654321"].subnet_id == "subnet-87654321"
    error_message = "aws_ec2_client_vpn_network_association.this_subnets['subnet-87654321'].subnet_id did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_authorization_rule.this_internal_dns.target_network_cidr == "10.0.0.2/32"
    error_message = "aws_ec2_client_vpn_authorization_rule.this_internal_dns.target_network_cidr did not match expected value"
  }

  assert {
    condition     = length(aws_ec2_client_vpn_authorization_rule.this_subnets) == 2
    error_message = "length(aws_ec2_client_vpn_authorization_rule.this_subnets) did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_authorization_rule.this_subnets["10.0.0.0/24"].target_network_cidr == "10.0.0.0/24"
    error_message = "aws_ec2_client_vpn_authorization_rule.this_subnets['10.0.0.0/24'].target_network_cidr did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_authorization_rule.this_subnets["10.0.0.0/24"].access_group_id == "12345678-abcd-1234-efgh-123456789012"
    error_message = "aws_ec2_client_vpn_authorization_rule.this_subnets['10.0.0.0/24'].access_group_id did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_authorization_rule.this_subnets["10.1.0.0/24"].target_network_cidr == "10.1.0.0/24"
    error_message = "aws_ec2_client_vpn_authorization_rule.this_subnets['10.1.0.0/24'].target_network_cidr did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_authorization_rule.this_subnets["10.1.0.0/24"].access_group_id == "12345678-abcd-1234-efgh-123456789012"
    error_message = "aws_ec2_client_vpn_authorization_rule.this_subnets['10.1.0.0/24'].access_group_id did not match expected value"
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/client-vpn-endpoint/vpn"
    error_message = "aws_cloudwatch_log_group.this.name did not match expected value"
  }
}
