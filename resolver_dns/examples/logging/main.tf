#
# Resolver DNS query logging only
#
module "logging" {
  source            = "../../"
  vpc_id            = aws_vpc.test.id
  billing_tag_value = "Terratest"
}

resource "aws_vpc" "test" {
  cidr_block = "10.10.0.0/16"
}
