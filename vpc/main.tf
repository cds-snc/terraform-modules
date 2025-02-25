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
*
* ![Diagram of the Single Zone architecture](./docs/single_zone.png)
* 
* 
* ### Breaking change with v9.0.0
* If you upgrade to v9.0.0 or above from a lower version, the ```high_availability``` flag is deprecated and no longer available. You will need to do the following in order to upgrade to a higher version: 
* 1. Remove the ```high_availability``` flag 
* 2. Instead add the following to your code:
*  ```
*    availability_zones = 3
*    cidrsubnet_newbits = 8
* ```
* 3. Run terraform/terragrunt plan. You should have no changes in your infrastucture.
*
*/

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_vpc"
  })

}

resource "aws_eip" "nat" {
  count = var.enable_eip ? local.nat_gateway_count : 0
  # checkov:skip=CKV2_AWS_19:EIP is used by NAT Gateway
  domain = "vpc"
  tags = merge(local.common_tags, {
    Name = "${var.name}-eip${count.index}"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.nat_gateway_count

  allocation_id     = length(local.nat_gateway_ips) > 0 ? element(local.nat_gateway_ips, var.single_nat_gateway ? 0 : count.index) : null
  subnet_id         = element(aws_subnet.public.*.id, var.single_nat_gateway ? 0 : count.index)
  connectivity_type = var.enable_eip ? "public" : "private"

  tags = merge(local.common_tags, {
    Name = "${var.name}-natgw-${count.index}"
  })

  depends_on = [aws_internet_gateway.gw]
}

locals {
  // If a single subnet then use 10 for newbits, otherwise use 8
  private_cidr_blocks = [for i in range(local.max_subnet_length) : cidrsubnet(aws_vpc.main.cidr_block, var.cidrsubnet_newbits, i)]
  public_cidr_blocks  = [for i in range(local.max_subnet_length) : cidrsubnet(aws_vpc.main.cidr_block, var.cidrsubnet_newbits, i + local.max_subnet_length)]
}

resource "aws_subnet" "private" {
  count             = local.max_subnet_length
  vpc_id            = aws_vpc.main.id
  availability_zone = element(local.zone_names, count.index)
  cidr_block        = length(var.private_subnets) == 0 ? element(local.private_cidr_blocks, count.index) : element(var.private_subnets, count.index)

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
  cidr_block        = length(var.public_subnets) == 0 ? element(local.public_cidr_blocks, count.index) : element(var.public_subnets, count.index)

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
