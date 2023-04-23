locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  conformance_yaml = yamldecode(file("${path.module}/Operational-Best-Practices-for-CCCS-Medium.yaml"))
  conformance_yaml_without_excluded_rules = {
    for k, v in local.conformance_yaml.Resources : k => v if !contains(var.excluded_rules, k)
  }

  custom_conformance_pack = try(yamldecode(file(var.custom_conformance_pack_path)), {})

  modified_conformance_pack = {
    Parameters = merge(local.conformance_yaml.Parameters, try(local.custom_conformance_pack.Parameters, {}))
    Resources  = merge(local.conformance_yaml_without_excluded_rules, try(local.custom_conformance_pack.Resources, {}))
    Conditions = merge(local.conformance_yaml.Conditions, try(local.custom_conformance_pack.Conditions, {}))
  }
}
