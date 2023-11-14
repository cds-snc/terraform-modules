provider "aws" {
  region = "ca-central-1"
}

variables {
  name = "tests"
}

# Single zone VPC (default created by the module)
run "default" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block did not match expected value"
  }

  assert {
    condition     = length(aws_eip.nat) == 1
    error_message = "AWS EIP count did not match expected value"
  }

  assert {
    condition     = length(aws_nat_gateway.nat_gw) == 1
    error_message = "AWS NAT gateway count did not match expected value"
  }

  assert {
    condition     = aws_nat_gateway.nat_gw[0].connectivity_type == "public"
    error_message = "AWS NAT gateway connectivity_type did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.private) == 1
    error_message = "AWS subnet private count did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.private) == 1
    error_message = "AWS subnet private count did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[0].availability_zone == data.aws_availability_zones.available.names[0]
    error_message = "AWS subnet private availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[0].cidr_block == "10.0.0.0/26"
    error_message = "AWS subnet private cidr_block did not match expected value"
  }

  assert {
    condition     = length(aws_subnet.public) == 1
    error_message = "AWS subnet public count did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[0].availability_zone == data.aws_availability_zones.available.names[0]
    error_message = "AWS subnet public availability_zone did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[0].cidr_block == "10.0.0.64/26"
    error_message = "AWS subnet public cidr_block did not match expected value"
  }

  assert {
    condition     = length(aws_default_route_table.default.route) == 0
    error_message = "AWS default route table route count did not match expected value"
  }

  assert {
    condition     = length(aws_flow_log.flow_logs) == 0
    error_message = "AWS flow log count did not match expected value"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.flow_logs) == 0
    error_message = "AWS cloudwatch log group count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role.flow_logs) == 0
    error_message = "AWS iam role count did not match expected value"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.vpc_flow_logs_service_principal) == 0
    error_message = "AWS iam policy document count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc_metrics_flow_logs_write_policy_attach) == 0
    error_message = "AWS iam role policy attachment count did not match expected value"
  }

  assert {
    condition     = length(aws_iam_policy.vpc_metrics_flow_logs_write_policy) == 0
    error_message = "AWS iam policy count did not match expected value"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.vpc_metrics_flow_logs_write) == 0
    error_message = "AWS iam policy document count did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_ssh[0].cidr_block == "0.0.0.0/0"
    error_message = "AWS NACL rule block SSH cidr_block did not match expected value"
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
    condition     = aws_network_acl_rule.block_rdp[0].from_port == 3389
    error_message = "AWS NACL rule block RDP from_port did not match expected value"
  }

  assert {
    condition     = aws_network_acl_rule.block_rdp[0].to_port == 3389
    error_message = "AWS NACL rule block RDP to_port did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_egress_443) == 0
    error_message = "AWS NACL rule https_request_egress_443 count did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_egress_ephemeral) == 0
    error_message = "AWS NACL rule https_request_out_egress_ephemeral count did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_response_ingress_443) == 0
    error_message = "AWS NACL rule https_request_out_response_ingress_443 count did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_out_response_ingress_ephemeral) == 0
    error_message = "AWS NACL rule https_request_out_response_ingress_ephemeral count did not match expected value"
  }

  assert {
    condition     = length(aws_network_acl_rule.https_request_in_ingress_443) == 0
    error_message = "AWS NACL rule https_request_in_ingress_443 count did not match expected value"
  }

  assert {
    condition     = length(aws_route_table.private) == 1
    error_message = "AWS route table private count did not match exected value"
  }

  assert {
    condition     = length(aws_route.private_nat_gateway) == 1
    error_message = "AWS route private_nat_gateway count did not match exected value"
  }

  assert {
    condition     = aws_route.private_nat_gateway[0].destination_cidr_block == "0.0.0.0/0"
    error_message = "AWS route private_nat_gateway destination_cidr_block did not match exected value"
  }

  assert {
    condition     = length(aws_route_table_association.private) == 1
    error_message = "AWS route table association private count did not match exected value"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 1
    error_message = "AWS route table association public count did not match exected value"
  }

  assert {
    condition     = aws_route.public_internet_gateway.destination_cidr_block == "0.0.0.0/0"
    error_message = "AWS route public_internet_gateway destination_cidr_block did not match exected value"
  }
}
