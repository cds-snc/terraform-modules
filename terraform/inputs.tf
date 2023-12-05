variable "account_id" {
  description = "(Required) The AWS account to create resources in."
  type        = string
}

variable "billing_code" {
  description = "(Required) The billing code to tag resources with."
  type        = string
}

variable "region" {
  description = "(Required) The region to create resources in."
  type        = string
}
