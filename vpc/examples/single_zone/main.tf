# VPC for development work that creates one subnet 
# in the region's first availability zone
module "single_zone_vpc" {
  source = "../../"
  name   = "single_zone"

  high_availability = false
  enable_flow_log   = false
  block_ssh         = true
  block_rdp         = true
  enable_eip        = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Operations"
}

output "vpc_id" {
  value = module.single_zone_vpc.vpc_id
}
