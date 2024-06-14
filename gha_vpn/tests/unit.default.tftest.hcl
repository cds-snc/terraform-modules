provider "aws" {
  region = "ca-central-1"
}

variables {
  endpoint_name                     = "vpn"
  access_group_id                   = "12345678-abcd-1234-efgh-123456789012"
  vpc_id                            = "vpc-12345678"
  vpc_cidr_block                    = "10.0.0.0/16"
  subnet_cidr_blocks                = ["10.0.0.0/24", "10.1.0.0/24"]
  acm_certificate_arn               = "arn:aws:acm:ca-central-1:123456789012:certificate/12345678-abcd-1234-efgh-123456789012"
}

run "default" {
  command = plan

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.description == "vpn"
    error_message = "aws_ec2_client_vpn_endpoint.this.description did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.vpc_id == "vpc-12345678"
    error_message = "aws_ec2_client_vpn_endpoint.this.vpc_id did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.server_certificate_arn == "arn:aws:acm:ca-central-1:123456789012:certificate/12345678-abcd-1234-efgh-123456789012"
    error_message = "aws_ec2_client_vpn_endpoint.this.server_certificate_arn did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.client_cidr_block == "172.16.0.0/22"
    error_message = "aws_ec2_client_vpn_endpoint.this.client_cidr_block did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.session_timeout_hours == 8
    error_message = "aws_ec2_client_vpn_endpoint.this.session_timeout_hours did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.self_service_portal == "disabled"
    error_message = "aws_ec2_client_vpn_endpoint.this.self_service_portal did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.split_tunnel == true
    error_message = "aws_ec2_client_vpn_endpoint.this.split_tunnel did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.transport_protocol == "udp"
    error_message = "aws_ec2_client_vpn_endpoint.this.transport_protocol did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.dns_servers[0] == "10.0.0.2"
    error_message = "aws_ec2_client_vpn_endpoint.this.dns_servers[0] did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.dns_servers[1] == "8.8.8.8"
    error_message = "aws_ec2_client_vpn_endpoint.this.dns_servers[1] did not match expected value"
  }

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.client_login_banner_options[0].banner_text == "This is a private network.  Only authorized users may connect and should take care not to cause service disruptions."
    error_message = "aws_ec2_client_vpn_endpoint.this.client_login_banner_options[0].banner_text did not match expected value"
  }

  assert {
    condition     = length(aws_ec2_client_vpn_network_association.this_subnets) == 0
    error_message = "length(aws_ec2_client_vpn_network_association.this_subnets) did not match expected value"
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
