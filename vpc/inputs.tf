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

variable "availability_zones" {
  description = "(Optional, default '1') The number of availability zones to use"
  type        = number
  default     = 1
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

variable "cidr" {
  description = "(Optional, default '10.0.0.0/16') The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "(Optional, default []) A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "(Optional, default []) A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "cidrsubnet_newbits" {
  type        = number
  default     = 10
  description = "(Optional, default '10') The number of additional bits with which to extend the cidr subnet prefix"
}