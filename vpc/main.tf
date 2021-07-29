/* 
* # VPC
* This module creates a vpc with 2 subnets, one public and one private.
* The public subnet is attached to an internet gateway and a public IP address.
*
* ## Architecture
* This allows you to set two modes high availability and single zone mode.
* 
* ### High Availability Mode
* *Please Note:* This might not work outside of ca-central-1
* ![Diagram of the High Availiablity Zone architecture](https://raw.githubusercontent.com/cds-snc/terraform-modules/feat/vpc_diagram/vpc/arch/high_availaiblity_zone.svg)
* 
* ### Single Zone mode
* *Please Note:* You probably don't want to use this for production grade stuff.
* ![Diagram of the Single Zone architecture](https://raw.githubusercontent.com/cds-snc/terraform-modules/feat/vpc_diagram/vpc/arch/single_zone.svg)
* 
*/

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_vpc"
  })

}

resource "aws_eip" "nat" {
  count = local.max_subnet_length
  # checkov:skip=CKV2_AWS_19:EIP is used by NAT Gateway
  vpc = true
  tags = merge(local.common_tags, {
    Name = "${var.name}-eip${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.max_subnet_length

  allocation_id = element(local.nat_gateway_ips, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(local.common_tags, {
    Name = "${var.name}-natgw-${count.index}"
  })

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
  count             = local.max_subnet_length
  vpc_id            = aws_vpc.main.id
  availability_zone = element(local.zone_names, count.index)
  cidr_block        = var.high_availability ? cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) : cidrsubnet(aws_vpc.main.cidr_block, 10, 0)

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_subnet_${element(local.zone_names, count.index)}"
  })


  timeouts {
    delete = "40m"
  }
}

resource "aws_subnet" "public" {
  count             = local.max_subnet_length
  vpc_id            = aws_vpc.main.id
  availability_zone = element(local.zone_names, count.index)
  cidr_block        = var.high_availability ? cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + local.max_subnet_length) : cidrsubnet(aws_vpc.main.cidr_block, 10, 1)

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_subnet_${element(local.zone_names, count.index)}"
  })
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_internet_gateway"
  })

}

