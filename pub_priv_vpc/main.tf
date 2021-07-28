/* Public/Private VPC
* This module creates a vpc with 2 subnets, one public and one private.
* The public subnet is attached to an internet gateway and a public IP address.
* The private subnet is connected to the public through a nat gateway.
*/

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_vpc"
  })

}

resource "aws_nat_gateway" "nat_gateway" {

  allocation_id = aws_eip.public_ip.id
  subnet_id     = aws_subnet.public.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-natgw"
  })

  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_eip" "public_ip" {
  # checkov:skip=CKV2_AWS_19:EIP is used by NAT Gateway
  vpc = true
}

resource "aws_subnet" "private" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_subnet"
  })

  availability_zone = "ca-central-1a"
  cidr_block        = "10.0.1.0/24"

  timeouts {
    delete = "40m"
  }
}

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_subnet"
  })

  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_internet_gateway"
  })

}

