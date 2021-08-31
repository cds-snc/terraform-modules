# VPC for production that creates a subnet in all of a region's availability zones
module "high_availability_vpc" {
  source = "../../"
  name   = "high_availability"

  high_availability = true
  enable_flow_log   = true
  block_ssh         = false
  block_rdp         = false
  enable_eip        = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Operations"
}

output "vpc_id" {
  value = module.high_availability_vpc.vpc_id
}
