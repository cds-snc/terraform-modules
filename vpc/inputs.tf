variable "name" {
  description = "(required) the name of the vpc"
  type        = string
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

variable "high_availability" {
  description = "(Optional, default 'false') Create either one set of subnets or as many as there are VPCs"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "(Optional, default 'false') Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "block_ssh" {
  description = "(Optional, default 'true') Whether or not to block Port 22"
  type        = bool
  default     = true

}

variable "block_rdp" {
  description = "(Optional, default 'true') Whether or not to block Port 3389"
  type        = bool
  default     = true
}


variable "enable_eip" {
  description = "(Optional, default 'true') Enables Elastic IPs, disabling is mainly used for testing purposes"
  type        = bool
  default     = true
}
