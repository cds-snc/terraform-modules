/* # sentinel_alert_rule
*
* This module deploys an analytic rule to Azure Sentinel.
* 
* You'll need to provide the following:
* - Log Analytics Workspace ID
* - Query
* - Query Frequency
* - Query Period
* - Severity
* - Tactics
* - Trigger Operator
* - Trigger Threshold
* - Entity Mapping
* - Incident Configuration

*/



resource "random_uuid" "this" {
}

resource "azurerm_sentinel_alert_rule_scheduled" "this" {
  description                = var.description
  display_name               = var.display_name
  enabled                    = var.enabled
  log_analytics_workspace_id = var.workspace_id
  name                       = random_uuid.this.result
  query                      = var.query
  query_frequency            = var.query_frequency #"PT1H" "P1D" "PT5M"
  query_period               = var.query_period
  severity                   = var.severity
  suppression_duration       = var.suppression_duration
  suppression_enabled        = var.suppression_enabled
  tactics                    = var.tactics
  techniques                 = var.techniques
  trigger_operator           = var.trigger_operator
  trigger_threshold          = var.trigger_threshold
  custom_details             = var.custom_details


  # a dynamic block only when alert_description is in the query
  dynamic "alert_details_override" {
    for_each = can(regex("alert_description", var.query)) ? [1] : []
    content {
      description_format = "{{alert_description}}"
    }
  }

  # iterate over the list of entity_mapping and create a dynamic block for each one
  dynamic "entity_mapping" {
    for_each = var.entity_mapping
    content {
      entity_type = entity_mapping.value.entity_type

      dynamic "field_mapping" {
        for_each = entity_mapping.value.field_mapping
        content {
          column_name = field_mapping.value.column_name
          identifier  = field_mapping.value.identifier
        }
      }
    }
  }

  dynamic "incident_configuration" {
    for_each = var.incident_configuration
    content {
    }
  }


}
