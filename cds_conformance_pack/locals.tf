
locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }

  conformance_yaml = yamldecode(file("${path.module}/Operational-Best-Practices-for-CCCS-Medium.yaml"))
  conformance_yaml_without_excluded_rules = {
    for k, v in local.conformance_yaml.Resources : k => v if !contains(var.excluded_rules, k)
  }

  custom_conformance_pack_custom_conformance_pack_yaml_file_exists = can(file(var.custom_conformance_pack_path))
  parsed_custom_conformance_pack_yaml                              = yamldecode(file(var.custom_conformance_pack_path))

  required_keys = [
    "Resources"
  ]

  optional_keys = [
    "Conditions",
    "Parameters"
  ]

  modified_conformance_pack = {
    Parameters = local.conformance_yaml.Parameters
    Resources  = local.conformance_yaml_without_excluded_rules
    Conditions = local.conformance_yaml.Conditions
  }
}

resource "null_resource" "validate_yaml" {
  count = local.custom_conformance_pack_yaml_file_exists ? 1 : 0

  triggers = {
    validate_yaml = jsonencode(local.parsed_custom_conformance_pack_yaml)
  }

  provisioner "local-exec" {
    command = "echo 'YAML file is valid'"
  }

  lifecycle {
    ignore_changes = [
      triggers
    ]
  }

  depends_on = [
    local.parsed_custom_conformance_pack_yaml
  ]

  dynamic "required_key" {
    for_each = local.required_keys
    content {
      validate {
        condition     = contains(keys(local.parsed_custom_conformance_pack_yaml), required_key.value)
        error_message = "Missing required key '${required_key.value}' in YAML file"
      }
    }
  }

  dynamic "optional_key" {
    for_each = local.optional_keys
    content {
      validate {
        condition     = contains(keys(local.parsed_custom_conformance_pack_yaml), optional_key.value)
        error_message = "Unknown key '${optional_key.value}' in YAML file"
      }
    }
  }
}

