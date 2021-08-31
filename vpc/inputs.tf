variable "name" {
  description = "(Required) The name of the vpc"
  type        = string
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "high_availability" {
  description = "(Optional, default 'false') Create 3 public and 3 private subnets across 3 availability zones in the region."
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

variable "allow_https_request_out" {
  description = "(Optional, default 'false') Allow HTTPS connections on port 443 out to the internet"
  type        = bool
  default     = false
}

variable "allow_https_request_out_response" {
  description = "(Optional, default 'false') Allow a response back from the internet in reply to a request"
  type        = bool
  default     = false
}

variable "allow_https_request_in" {
  description = "(Optional, default 'false') Allow HTTPS connections on port 443 in from the internet"
  type        = bool
  default     = false
}

variable "allow_https_request_in_response" {
  description = "(Optional, default 'false') Allow a response back to the internet in reply to a request"
  type        = bool
  default     = false
}
