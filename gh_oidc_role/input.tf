
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "oidc_exists" {
  description = "(Optional, default false) If false, the OIDC provider will be created"
  type        = boolean
  default     = false
}

variable "org_name" {
  description = <<EOF
    (Optional)  The name of the org the workflow will be called from.
    In the format of http://github.com/`org_name`
  EOF
  type        = string
  default     = "cds-snc"
}

variable "roles" {
  description = <<EOF
  (Required) The list of roles to create for GH OIDC

  name: The name of the role to create

  repo_name: The name of the repo to authenticate
  If you use `*` this will allow this role to be used in any repo in the org identified in `org_name`

  claim: The claim that the token is allowed to be authorized from. 
  This allows you to further restrict where this role is allowed to be used.
  If you wanted to restrict to the main branch you could use a value like `ref:refs/heads/main`, if you don't want to restrict you can use `*`

  **Please Note:** You need to provide at least one role for this module to work.
  EOF

  type = set(object({
    name : string,
    repo_name : string,
    claim : string
  }))
}

variable "assume_policy" {
  type        = string
  description = "(Optional) Assume role JSON policy to attach to the oidc role"
  default     = "{}"
}
