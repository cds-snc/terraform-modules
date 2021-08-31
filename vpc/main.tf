/** 
* # Virtual Private Cloud (VPC)
*
* This module creates a pre-configured VPC with a pair of subnets split over one or many availability zones (AZ). Each of the AZs created has a public and private subnet. The public subnet has a public IP address attached and has a route to the internet. The private subnet has a route to the internet through a nat gateway.
*
* ## Architecture
*
* This module allows you to deploy two types of architecture high availability and single zone mode.
* 
* ### High Availability Mode
*
* **Please Note:** This might not work outside of ca-central-1
*
* High Availability mode deploys in each AZ in a region. This is what you should chose if you want to target Protected B, Medium Integrity, Medium Availability (PBMM).
* ![Diagram of the High Availiablity Zone architecture](./docs/high_availability_zone.png)
* 
* ### Single Zone mode
*
* **Please Note:** This should not be used in a PBMM Production environment.
*
* Single Zone mode deployes in the first AZ in a region that is found by the availability lookup. This will work for if you want to save money in dev.
* ![Diagram of the Single Zone architecture](./docs/single_zone.png)
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
  count = var.enable_eip ? local.max_subnet_length : 0
  # checkov:skip=CKV2_AWS_19:EIP is used by NAT Gateway
  vpc = true
  tags = merge(local.common_tags, {
    Name = "${var.name}-eip${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.max_subnet_length

  allocation_id     = length(local.nat_gateway_ips) > 0 ? element(local.nat_gateway_ips, count.index) : null
  subnet_id         = element(aws_subnet.public.*.id, count.index)
  connectivity_type = var.enable_eip ? "public" : "private"

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
    Tier = "Private"
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
    Tier = "Public"
  })
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_internet_gateway"
  })
}
