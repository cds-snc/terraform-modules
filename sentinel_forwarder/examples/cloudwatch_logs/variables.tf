variable "sentinel_customer_id" {
  description = "Customer ID to authenticate with the Sentinel service."
  type        = string
  sensitive   = true
}

variable "sentinel_shared_key" {
  description = "Shared key to authenticate with the Sentinel service."
  type        = string
  sensitive   = true
}
