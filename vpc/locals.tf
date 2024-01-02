locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
  zone_names        = [for i in range(var.availability_zones) : data.aws_availability_zones.available.names[i]]
  max_subnet_length = length(local.zone_names)
  nat_gateway_count = var.single_nat_gateway ? 1 : local.max_subnet_length
  nat_gateway_ips   = var.enable_eip ? tolist(aws_eip.nat.*.id) : [""]
}

data "aws_availability_zones" "available" {
  state = "available"
}
