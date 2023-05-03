locals {
  common_tags = {
    (var.billing_tag_key)  = var.billing_tag_value
    Terraform              = "true"
    Log_Bucket             = lookup(var.tags, "Log_Bucket", "false")
    (var.critical_tag_key) = var.critical_tag_value ? "true" : "false"
  }
}
