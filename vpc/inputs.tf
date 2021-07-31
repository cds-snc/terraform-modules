variable "name" {
  description = "(required) the name of the vpc"
  type        = string
}

variable "billing_tag_key" {
  description = "The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

variable "high_availability" {
  description = "Create either one set of subnets or as many as there are VPCs"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "block_ssh" {
  description = "Whether or not to block Port 22"
  type        = bool
  default     = true

}

variable "block_rdp" {
  description = "Whether or not to block Port 3389"
  type        = bool
  default     = true
}
