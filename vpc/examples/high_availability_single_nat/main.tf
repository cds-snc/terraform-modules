# VPC for production that creates a subnet in all of a region's availability zones
module "high_availability_single_nat_vpc" {
  source = "../../"
  name   = "high_availability_single_nat"

  high_availability = true
  enable_flow_log   = true

  # Only provision one NAT gateway to be shared by all your private subnets
  single_nat_gateway = true

  # Allow VPC resources to send requests out to the internet and recieve a response
  allow_https_request_out          = true
  allow_https_request_out_response = true

  # Allow users to send requests in from the internet and receive a response
  allow_https_request_in          = true
  allow_https_request_in_response = true

  block_ssh  = false
  block_rdp  = false
  enable_eip = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Operations"
}

output "vpc_id" {
  value = module.high_availability_single_nat_vpc.vpc_id
}
