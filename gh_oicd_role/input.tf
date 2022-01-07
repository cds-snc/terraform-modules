
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

    If you use `*` this will allow this role to be used in any repo in the org identified in `org_name`
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

variable "claim" {
  description = <<EOF
    (Optional) The claim that the token is allowed to be authorized from.
    This allows you to restrict to specific branches in your repo. 

    Defaults to `*` which allows you to use this token anywhere in your repo. 

    If you wanted to restrict to the main branch you could use a value like `ref:refs/heads/main`
  EOF
  type        = string
  default     = "*"
}

variable "role_name" {
  description = "(Required) The name of the role to create"
  type        = string
}