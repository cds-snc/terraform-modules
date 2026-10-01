variable "name" {
  description = "(Required) The name of the AWS Backup vault."
  type        = string
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag."
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag."
  type        = string
}

variable "ssc_cbrid_tag_key" {
  description = "(Optional, default 'ssc_cbrid') The tag key for the SSC CBRID."
  type        = string
  default     = "ssc_cbrid"
}

variable "ssc_cbrid_tag_value" {
  description = "(Optional) The value of the SSC CBRID tag. If empty, the tag will not be applied."
  type        = string
  default     = "22DH"
}

variable "min_retention_days" {
  description = "(Optional) The minimum retention period in days accepted by the vault lock, up to three years."
  type        = number
  default     = null

  validation {
    condition     = var.min_retention_days == null ? true : (var.min_retention_days >= 1 && var.min_retention_days <= 1095 && floor(var.min_retention_days) == var.min_retention_days)
    error_message = "min_retention_days must be a whole number between 1 and 1095 when set."
  }
}

variable "max_retention_days" {
  description = "(Optional) The maximum retention period in days accepted by the vault lock, up to three years."
  type        = number
  default     = null

  validation {
    condition     = var.max_retention_days == null ? true : (var.max_retention_days >= 1 && var.max_retention_days <= 1095 && floor(var.max_retention_days) == var.max_retention_days)
    error_message = "max_retention_days must be a whole number between 1 and 1095 when set."
  }
}

variable "changeable_for_days" {
  description = "(Optional) The number of days before a compliance-mode vault lock becomes immutable. Omit to use governance mode."
  type        = number
  default     = null

  validation {
    condition     = var.changeable_for_days == null ? true : (var.changeable_for_days >= 3 && var.changeable_for_days <= 36500 && floor(var.changeable_for_days) == var.changeable_for_days)
    error_message = "changeable_for_days must be a whole number between 3 and 36500 when set."
  }
}