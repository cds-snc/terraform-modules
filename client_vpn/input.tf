variable "access_group_id" {
  description = "(Required) IAM Identity Center access group ID that is authorized to access the private subnets."
  type        = string
  sensitive   = true
}

variable "acm_certificate_arn" {
  description = "(Required) The ARN of the ACM server certificate to use for VPN client connection encryption."
  type        = string
}

variable "banner_text" {
  description = "The text to display on the banner page when a user connects to the Client VPN endpoint."
  type        = string
  default     = "This is a private network.  Only authorized users may connect and should take care not to cause service disruptions."
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

variable "endpoint_name" {
  description = "(Required) The name of the VPN endpoint to create. It must only contain alphanumeric characters, hyphens and underscores."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.endpoint_name))
    error_message = "The endpoint_name must only contain alphanumeric characters, hyphens and underscores."
  }
}

variable "endpoint_cidr_block" {
  description = "(Optional, default '172.16.0.0/22') The CIDR block to use for the VPN endpoint."
  type        = string
  default     = "172.16.0.0/22"
}

variable "public_dns_servers" {
  description = "(Optional, default ['8.8.8.8']) Public DNS servers to add to the VPN."
  type        = list(string)
  default     = ["8.8.8.8"]
}

variable "self_service_portal" {
  description = "(Optional, default 'disabled') Should a self-service portal be created for users to download the VPN client software?"
  type        = string
  default     = "disabled"

  validation {
    condition     = can(regex("^(enabled|disabled)$", var.self_service_portal))
    error_message = "The self_service_portal must be 'enabled' or 'disabled'."
  }
}

variable "session_timeout_hours" {
  description = "(Optional, default 8) The maximum number of hours after which to automatically disconnect a session.  Allowed values are 8, 10, 12, 24"
  type        = number
  default     = 8

  validation {
    condition     = can(regex("^(8|10|12|24)$", var.session_timeout_hours))
    error_message = "The session_timeout_hours must be 8, 10, 12, or 24."
  }
}

variable "split_tunnel" {
  description = "(Optional, default true) Whether to enable split tunneling for the VPN endpoint."
  type        = bool
  default     = true
}

variable "subnet_cidr_blocks" {
  description = "(Required) CIDR blocks of the subnets to associate with the VPN endpoint."
  type        = list(string)
}

variable "subnet_ids" {
  description = "(Optional, default []) IDs of the subnets to associate with the VPN endpoint.  If left blank, no subnets will be associated with the VPN client endpoint, removing the $0.10/hour/association cost."
  type        = list(string)
  default     = []
}

variable "transport_protocol" {
  description = "(Optional, default 'udp') Transport protocol to use for the VPN endpoint.  Valid values are 'tcp' or 'udp'."
  type        = string
  default     = "udp"

  validation {
    condition     = can(regex("^(tcp|udp)$", var.transport_protocol))
    error_message = "The transport_protocol must be 'tcp' or 'udp'."
  }
}

variable "vpc_cidr_block" {
  description = "(Required) The CIDR block of the VPC to associate with the VPN endpoint."
  type        = string
}

variable "vpc_id" {
  description = "(Required) ID of the VPC to associate with the VPN endpoint."
  type        = string
}
variable "authentication_option" {
  description = "(Optional, default 'federated-authentication') The authentication option to use for the VPN endpoint.  Valid values are 'federated-authentication' or 'certificate-authentication'."
  type        = string
  default     = "federated-authentication"
}
variable "client_vpn_saml_metadata_document" {
  description = "(Required) The base64 encoded SAML metadata document for the Client VPN endpoint"
  type        = string
  default     = ""
  sensitive   = true
}

variable "client_vpn_self_service_saml_metadata_document" {
  description = "(Optional, default empty) The base64 encoded SAML metadata document for the Client VPN's self-service endpoint. The self_service_portal variable must be set to 'enabled' for this to take effect."
  type        = string
  default     = ""
  sensitive   = true
}
