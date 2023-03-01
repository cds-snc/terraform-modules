
variable "description" {
  type        = string
  description = "(Required) The description of the alert rule."
}

variable "display_name" {
  type        = string
  description = "(Required) The display name of the alert rule."
}


variable "workspace_id" {
  type        = string
  description = "(Required) The workspace that the alert is going to use"
}

variable "query" {
  type        = string
  description = "(Required) The query that will be used to create the alert rule."
}

variable "query_frequency" {
  type        = string
  description = "(Optional) The frequency of the query. Defaults to PT1H."
  default     = "PT1H"
  validation {
    # condition with regex should be  ISO 8601	duration format
    condition     = can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+W)?(?:\\d+D)?(?:T(\\d+H)?(\\d+M)?)?$", var.query_frequency))
    error_message = "The Frequency must be in ISO 8601 duration format(e.g. P1D PT1H)."
  }
}
variable "query_period" {
  type        = string
  description = "(Optional) The period of the query. Defaults to PT1H."
  default     = "PT1H"
  validation {
    # condition with regex should be  ISO 8601	duration format
    condition     = can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+W)?(?:\\d+D)?(?:T(\\d+H)?(\\d+M)?)?$", var.query_period))
    error_message = "The query period must be in ISO 8601 duration format(e.g. P1D PT1H)."
  }
}

variable "tactics" {
  type        = list(string)
  description = "(Optional) The tactics of the alert rule. Defaults to [InitialAccess]."
  default     = ["InitialAccess"]
  validation {
    condition     = can(regex("^(InitialAccess|Execution|Persistence|PrivilegeEscalation|DefenseEvasion|CredentialAccess|Discovery|LateralMovement|Collection|Exfiltration|CommandAndControl|Impact|ImpairProcessControl|InhibitResponseFunction|PreAttack|Reconnaissance|ResourceDevelopment)$", join(",", var.tactics)))
    error_message = "The tactics must be in the list of [InitialAccess, Execution, Persistence, PrivilegeEscalation, DefenseEvasion, CredentialAccess, Discovery, LateralMovement, Collection, Exfiltration, CommandAndControl, Impact, ImpairProcessControl, InhibitResponseFunction, PreAttack, Reconnaissance, ResourceDevelopment]."
  }
}

variable "severity" {
  type        = string
  description = "(Optional) The severity of the alert rule. Defaults to High."
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

