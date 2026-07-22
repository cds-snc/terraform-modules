
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

variable "oidc_exists" {
  description = <<EOF
    (Optional, default true) If false, the OIDC provider will be created.
    If you are not on the new Control Tower Landing zone you may need to set this to false as your account may not have an OIDC Github Identity Provider configured.
  EOF

  type    = bool
  default = true
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
  (Optional) The list of roles to create for GH OIDC. Leaving this empty is valid only when `oidc_exists = false`.
  With the default `oidc_exists = true`, an empty `roles` list results in the module creating no resources.
  As a result, if the variable `oidc_exists = true`, then you must pass non-empty values to the `roles` list.

  name: The name of the role to create. 

  repo_name: The name of the repo to authenticate
  If you use `*` this will allow this role to be used in any repo in the org identified in `org_name`

  claim: The claim that the token is allowed to be authorized from. 
  This allows you to further restrict where this role is allowed to be used.
  If you wanted to restrict to the main branch you could use a value like `ref:refs/heads/main`, if you don't want to restrict you can use `*`

  claims: (Optional) A list of subject claims to allow, used when a single role needs to be assumable
  from more than one repo, branch or org. Each entry supports:
    - repo_name: (Required) The name of the repo to authenticate.
    - claim:     (Required) The claim that the token is allowed to be authorized from.
    - org_name:  (Optional) Overrides the module-level `org_name` for this entry. Useful when the same
                 role must trust more than one org (e.g. `cds-snc` and `cds-snc@org_id`).
  When `claims` is set it takes precedence over the single `repo_name`/`claim` pair.
  EOF

  type = set(object({
    name : string,
    repo_name : optional(string),
    claim : optional(string),
    claims : optional(list(object({
      repo_name : string,
      claim : string,
      org_name : optional(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.roles :
      length(r.claims) > 0 || (r.repo_name != null && r.claim != null)
    ])
    error_message = "Each role must set either `claims` (a non-empty list) or both `repo_name` and `claim`."
  }
}

variable "assume_policy" {
  type        = string
  description = "(Optional) Assume role JSON policy to attach to the oidc role"
  default     = "{}"
}
