# VPC for work that requires custom cidr and private/subnet ranges
module "custom_cidr_and_subnets_vpc" {
  source = "../../"
  name   = "custom_cidr_and_subnets"

  cidr              = "172.16.0.0/16"
  public_subnets    = ["172.16.0.0/20", "172.16.16.0/20", "172.16.32.0/20"]
  private_subnets   = ["172.16.128.0/20", "172.16.144.0/20", "172.16.160.0/20"]
  high_availability = true
  enable_flow_log   = true
  block_ssh         = true
  block_rdp         = true
  enable_eip        = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Operations"
}

output "vpc_id" {
  value = module.custom_cidr_and_subnets_vpc.vpc_id
}
