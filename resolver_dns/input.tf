variable "allowed_domains" {
  description = "(Optional) List of domains to allow through the DNS firewall.  Required if `firewall_enabled` is true."
  type        = list(string)
  default     = ["*."]

  validation {
    condition = alltrue([
      for domain in var.allowed_domains : endswith(domain, ".")
    ])
    error_message = "Domains must end with a period: example.com."
  }
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

variable "ssc_cbrid_tag_key" {
  description = "(Optional, default 'ssc_cbrid') The tag key for the SSC CBRID"
  type        = string
  default     = "ssc_cbrid"
}

variable "ssc_cbrid_tag_value" {
  description = "(Optional) The value of the SSC CBRID tag"
  type        = string
  default     = "22DH"
}

variable "block_action" {
  description = "(Optional) Action to take for blocked domains. BLOCK prevents resolution; ALERT only logs the query without blocking."
  type        = string
  default     = "BLOCK"

  validation {
    condition     = contains(["BLOCK", "ALERT"], var.block_action)
    error_message = "Valid values are BLOCK and ALERT."
  }
}

variable "firewall_enabled" {
  description = "(Optional) Should the resolver DNS firewall be enabled"
  type        = bool
  default     = false
}

variable "firewall_domain_redirection_action" {
  description = "(Optional) Controls how CNAME redirection chains are evaluated by the allow rule. INSPECT_REDIRECTION_DOMAIN checks every domain in the chain; TRUST_REDIRECTION_DOMAIN only checks the originally queried domain."
  type        = string
  default     = "INSPECT_REDIRECTION_DOMAIN"

  validation {
    condition     = contains(["INSPECT_REDIRECTION_DOMAIN", "TRUST_REDIRECTION_DOMAIN"], var.firewall_domain_redirection_action)
    error_message = "Valid values are INSPECT_REDIRECTION_DOMAIN and TRUST_REDIRECTION_DOMAIN."
  }
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC to associate the query log and firewall with"
  type        = string
}
