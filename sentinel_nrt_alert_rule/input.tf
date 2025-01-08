
variable "description" {
  type        = string
  description = "(Required) The description of the alert rule."
}

variable "display_name" {
  type        = string
  description = "(Required) The display name of the alert rule."
}

variable "name" {
  type        = string
  description = "(Optional) The name of the azurerm_sentinel_alert_rule_scheduled. If not provided, a random UUID will be used."
  default     = ""
}


variable "workspace_id" {
  type        = string
  description = "(Required) The workspace that the alert is going to use"
}

variable "query" {
  type        = string
  description = "(Required) The query that will be used to create the alert rule."
}


variable "tactics" {
  type        = list(string)
  description = "(Optional) The tactics of the alert rule. Defaults to [InitialAccess]."
  default     = ["InitialAccess"]
  validation {
    condition = alltrue([
      for tactic in var.tactics : can(regex("^(InitialAccess|Execution|Persistence|PrivilegeEscalation|DefenseEvasion|CredentialAccess|Discovery|LateralMovement|Collection|Exfiltration|CommandAndControl|Impact|ImpairProcessControl|InhibitResponseFunction|PreAttack|Reconnaissance|ResourceDevelopment)$", tactic))
    ])
    error_message = "The tactics must be in the list of [InitialAccess, Execution, Persistence, PrivilegeEscalation, DefenseEvasion, CredentialAccess, Discovery, LateralMovement, Collection, Exfiltration, CommandAndControl, Impact, ImpairProcessControl, InhibitResponseFunction, PreAttack, Reconnaissance, ResourceDevelopment]."
  }
}
variable "techniques" {
  type        = list(string)
  description = "(Optional) The techniques of the alert rule. Defaults to null"
  default     = null
}

variable "severity" {
  type        = string
  description = "(Optional) The severity of the alert rule. Defaults to Medium."
  default     = "Medium"
  validation {
    condition     = can(regex("^(High|Medium|Low)$", var.severity))
    error_message = "The severity must be in the list of [High, Medium, Low]."
  }
}

variable "suppression_duration" {
  type        = string
  description = "(Optional) The suppression duration of the alert rule. Defaults to PT1H."
  default     = "PT1H"
  validation {
    # condition with regex should be  ISO 8601	duration format
    condition     = can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+W)?(?:\\d+D)?(?:T(\\d+H)?(\\d+M)?)?$", var.suppression_duration))
    error_message = "The suppression duration must be in ISO 8601 duration format(e.g. P1D PT1H)."
  }
}

variable "suppression_enabled" {
  type        = bool
  description = "(Optional) The suppression enabled of the alert rule. Defaults to false."
  default     = false
}

#define variable for entity_mapping with a list of maps
variable "entity_mapping" {
  type = list(object({
    entity_type = string
    field_mapping = list(object({
      column_name = string
      identifier  = string
    }))
  }))
  description = "(Optional) The entity mapping of the alert rule."
  default     = []
}

variable "custom_details" {
  type        = map(string)
  description = "(Optional) The custom details of the alert rule."
  default     = {}
}

variable "incident_configuration" {
  type        = any
  description = "(Optional) The incident configuration of the alert rule."
  default = {
    create_incident_enabled = true

    grouping = {
      enabled                 = false
      entity_matching_method  = "AllEntities"
      group_by_alert_details  = []
      group_by_custom_details = []
      group_by_entities       = []
      lookback_duration       = "PT5H"
      reopen_closed_incidents = false
    }
  }
}


variable "enabled" {
  type        = bool
  description = "(Optional) The enabled status of the alert rule. Defaults to true."
  default     = true
}

variable "event_grouping" {
  type        = map(string)
  description = "(Optional) The event grouping of the alert rule."
  default = {
    aggregation_method = "AlertPerResult"
  }
  validation {
    condition     = can(regex("^(AlertPerResult|SingleAlert)$", var.event_grouping.aggregation_method))
    error_message = "The aggregation method must be in the list of [AlertPerResult, SingleAlert]."
  }


}
