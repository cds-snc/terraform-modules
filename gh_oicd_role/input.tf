
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "repo" {
  description = <<EOF
    (Required) The name of the repo that will be the workflow will be called from.
    In the format of http://github.com/cds-snc/`repo`
  EOF
  type        = string
}

variable "org_name" {
  description = <<EOF
    (Optional)  The name of the org the workflow will be called from.
    In the format of http://github.com/`org_name`
  EOF
  type        = string
  default     = "cds-snc"
}
