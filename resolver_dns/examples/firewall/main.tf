#
# Resolver DNS query logging and firewall.  Only queries to the following domains
# will be allowed to resolve:
# - canada.ca
# - *.amazonaws.com (all subdomains of amazonaws.com)
#
module "firewall" {
  source = "../../"
  vpc_id = aws_vpc.test.id

  firewall_enabled = true
  allowed_domains  = ["canada.ca.", "*.amazonaws.com."]

  billing_tag_value = "Terratest"
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
}
