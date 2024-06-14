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

}

run "customized" {
  command = plan

  assert {
    condition     = aws_ec2_client_vpn_endpoint.this.client_cidr_block == "192.168.0.0/24"
    error_message = "aws_ec2_client_vpn_endpoint.this.client_cidr_block did not match expected value"
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
