
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "account_id" {
  description = "(Required) The ID of the AWS account to add permissions for"
  type        = string
}


variable "lock_table_name" {
  description = "(Optional) The name of the table the locks for the state file are in"
  type        = string
  default     = "terraform-state-lock-dynamo"
}

variable "bucket_name" {
  description = "(Required) The name of the s3 bucket the state is being kept in"
  type        = string
}

variable "region" {
  description = "(Optional) The region the resources are in"
  type        = string
  default     = "ca-central-1"
}

variable "role_name" {
  description = "(Required) The name of the role to attach the policy to"
  type        = string
}

variable "policy_name" {

  description = <<EOF
    (Optional) The name of the policy that will be attached to the role.
    **Please Note:** This is only needed to be set if the default value conflicts with an existing policy name in this account.
  EOF

  type    = string
  default = "TFPlan"
}
