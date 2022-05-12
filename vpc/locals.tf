locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
  zone_names        = var.high_availability ? data.aws_availability_zones.available.names : [data.aws_availability_zones.available.names[0]]
  max_subnet_length = length(local.zone_names)
  nat_gateway_count = var.enable_eip ? var.single_nat_gateway ? 1 : local.max_subnet_length : 0
  nat_gateway_ips   = var.enable_eip ? tolist(aws_eip.nat.*.id) : [""]
}

data "aws_availability_zones" "available" {
  state = "available"
}
