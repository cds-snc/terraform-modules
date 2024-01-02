provider "aws" {
  region = "ca-central-1"
}

variables {
  name               = "tests"
  enable_eip         = false
  cidr               = "172.16.0.0/16"
  availability_zones = 3
  public_subnets     = ["172.16.0.0/20", "172.16.16.0/20", "172.16.32.0/20"]
  private_subnets    = ["172.16.128.0/20", "172.16.144.0/20", "172.16.160.0/20"]
}

# Multi zone VPC with custom subnet CIDR ranges
run "custom_subnets" {
  command = plan

  assert {
    condition     = length(aws_eip.nat) == 0
    error_message = "AWS EIP count did not match expected value"
  }

  assert {
    condition     = length(aws_nat_gateway.nat_gw) == 3
    error_message = "AWS NAT gateway count did not match expected value"
  }

  assert {
    condition     = aws_nat_gateway.nat_gw[0].connectivity_type == "private"
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
    condition     = aws_subnet.private[0].cidr_block == "172.16.128.0/20"
    error_message = "AWS subnet private 1 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[1].cidr_block == "172.16.144.0/20"
    error_message = "AWS subnet private 2 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.private[2].cidr_block == "172.16.160.0/20"
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
    condition     = aws_subnet.public[0].cidr_block == "172.16.0.0/20"
    error_message = "AWS subnet public 1 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[1].cidr_block == "172.16.16.0/20"
    error_message = "AWS subnet public 2 cidr_block did not match expected value"
  }

  assert {
    condition     = aws_subnet.public[2].cidr_block == "172.16.32.0/20"
    error_message = "AWS subnet public 3 cidr_block did not match expected value"
  }

  assert {
    condition     = length(aws_default_route_table.default.route) == 0
    error_message = "AWS default route table route count did not match expected value"
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
    condition     = length(aws_route_table_association.private) == 3
    error_message = "AWS route table association private count did not match exected value"
  }

  assert {
    condition     = length(aws_route_table_association.public) == 3
    error_message = "AWS route table association public count did not match exected value"
  }
}
