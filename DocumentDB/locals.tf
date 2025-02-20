locals {
  common_tags = merge(
    var.default_tags,
    {
      CostCentre = var.billing_code
    }
  )
}