provider "aws" {
  region = "ca-central-1"
}

variables {
  name                             = "tests"
  cidr                             = "10.10.0.0/24"
  enable_flow_log                  = true
  aws_availability_zones           = 3
  allow_https_request_out          = true
  allow_https_request_out_response = true
  allow_https_request_in           = true
  allow_https_request_in_response  = true
}

# Multi zone VPC
run "high_availability" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.10.0.0/24"
    error_message = "VPC CIDR block did not match expected value"
  }

  assert {
    condition     = length(aws_eip.nat) == 3
    error_message = "AWS EIP count did not match expected value"
  }

  assert {
    condition     = length(aws_nat_gateway.nat_gw) == 3
    error_message = "AWS NAT gateway count did not match expected value"
  }

  assert {
    condition     = aws_nat_gateway.nat_gw[0].connectivity_type == "public"
    error_message = "AWS NAT gateway connectivity_type did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "AWS subnet private count did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "AWS subnet private count did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[0].availability_zone == data.aws_availability_zones.available.names[0]
    error_message = "AWS subnet private 1 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[1].availability_zone == data.aws_availability_zones.available.names[1]
    error_message = "AWS subnet private 2 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[2].availability_zone == data.aws_availability_zones.available.names[2]
    error_message = "AWS subnet private 3 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[0].cidr_block == "10.10.0.0/32"
    error_message = "AWS subnet private 1 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[1].cidr_block == "10.10.0.1/32"
    error_message = "AWS subnet private 2 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[2].cidr_block == "10.10.0.2/32"
    error_message = "AWS subnet private 3 cidr_block did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "AWS subnet public count did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[0].availability_zone == data.aws_availability_zones.available.names[0]
    error_message = "AWS subnet public 1 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[1].availability_zone == data.aws_availability_zones.available.names[1]
    error_message = "AWS subnet public 2 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[2].availability_zone == data.aws_availability_zones.available.names[2]
    error_message = "AWS subnet public 3 availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[0].cidr_block == "10.10.0.3/32"
    error_message = "AWS subnet public 1 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[1].cidr_block == "10.10.0.4/32"
    error_message = "AWS subnet public 2 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[2].cidr_block == "10.10.0.5/32"
    error_message = "AWS subnet public 3 cidr_block did not match expected value"
  }

  assert {
    condition     = length(aws_default_route_table.default.route) == 0
    error_message = "AWS default route table route count did not match expected value"
  }

  assert {
    condition     = length(aws_flow_log.flow_logs) == 1
    error_message = "AWS flow log count did not match expected value"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.flow_logs) == 1
    error_message = "AWS cloudwatch log group count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role.flow_logs) == 1
    error_message = "AWS iam role count did not match expected value"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.vpc_flow_logs_service_principal) == 1
    error_message = "AWS iam policy document count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc_metrics_flow_logs_write_policy_attach) == 1
    error_message = "AWS iam role policy attachment count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_policy.vpc_metrics_flow_logs_write_policy) == 1
    error_message = "AWS iam policy count did not match expected value"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.vpc_metrics_flow_logs_write) == 1
    error_message = "AWS iam policy document count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_ssh[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule block SSH cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_ssh[0].rule_action == "deny"
    error_message = "AWS NACL rule block SSH rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_ssh[0].from_port == 22
    error_message = "AWS NACL rule block SSH from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_ssh[0].to_port == 22
    error_message = "AWS NACL rule block SSH to_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_rdp[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule block RDP cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_rdp[0].rule_action == "deny"
    error_message = "AWS NACL rule block RDP rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_rdp[0].from_port == 3389
    error_message = "AWS NACL rule block RDP from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_rdp[0].to_port == 3389
    error_message = "AWS NACL rule block RDP to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_egress_443) == 1
    error_message = "AWS NACL rule https_request_egress_443 count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_egress_443[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule https_request_egress_443 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_egress_443[0].rule_action == "allow"
    error_message = "AWS NACL rule https_request_egress_443 rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_egress_443[0].from_port == 443
    error_message = "AWS NACL rule https_request_egress_443 from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_egress_443[0].to_port == 443
    error_message = "AWS NACL rule https_request_egress_443 to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_egress_ephemeral) == 1
    error_message = "AWS NACL rule https_request_out_egress_ephemeral count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_egress_ephemeral[0].cidr_block == "10.10.0.0/24"
    error_message = "AWS NACL rule https_request_out_egress_ephemeral cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_egress_ephemeral[0].rule_action == "allow"
    error_message = "AWS NACL rule https_request_out_egress_ephemeral rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_egress_ephemeral[0].from_port == 1024
    error_message = "AWS NACL rule https_request_out_egress_ephemeral from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_egress_ephemeral[0].to_port == 65535
    error_message = "AWS NACL rule https_request_out_egress_ephemeral to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_response_ingress_443) == 1
    error_message = "AWS NACL rule https_request_out_response_ingress_443 count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_443[0].cidr_block == "10.10.0.0/24"
    error_message = "AWS NACL rule https_request_out_response_ingress_443 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_443[0].rule_action == "allow"
    error_message = "AWS NACL rule https_request_out_response_ingress_443 rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_443[0].from_port == 443
    error_message = "AWS NACL rule https_request_out_response_ingress_443 from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_443[0].to_port == 443
    error_message = "AWS NACL rule https_request_out_response_ingress_443 to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_response_ingress_ephemeral) == 1
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_ephemeral[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_ephemeral[0].rule_action == "allow"
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_ephemeral[0].from_port == 1024
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_out_response_ingress_ephemeral[0].to_port == 65535
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_in_ingress_443) == 1
    error_message = "AWS NACL rule https_request_in_ingress_443 count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_in_ingress_443[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule https_request_in_ingress_443 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_in_ingress_443[0].rule_action == "allow"
    error_message = "AWS NACL rule https_request_in_ingress_443 rule_action did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_in_ingress_443[0].from_port == 443
    error_message = "AWS NACL rule https_request_in_ingress_443 from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.https_request_in_ingress_443[0].to_port == 443
    error_message = "AWS NACL rule https_request_in_ingress_443 to_port did not match expected value"
  }

  assert {
    condition     = length(aws_route_table.private) == 3
    error_message = "AWS route table private count did not match exected value"
  }

  assert {
    condition     = length(aws_route.private_nat_gateway) == 3
    error_message = "AWS route private_nat_gateway count did not match exected value"
  }

  assert {
    condition     = aws_route.private_nat_gateway[0].destination_cidr_block == "0.0.0.0/0"
    error_message = "AWS route private_nat_gateway destination_cidr_block did not match exected value"
  }

  assert {
    condition     = length(aws_route_table_association.private) == 3
    error_message = "AWS route table association private count did not match exected value"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 3
    error_message = "AWS route table association public count did not match exected value"
  }

  assert {
    condition     = aws_route.public_internet_gateway.destination_cidr_block == "0.0.0.0/0"
    error_message = "AWS route public_internet_gateway destination_cidr_block did not match exected value"
  }
}
