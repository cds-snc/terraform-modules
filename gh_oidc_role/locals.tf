
locals {
  common_tags = merge(
    {
      (var.billing_tag_key) = var.billing_tag_value
      Terraform             = "true"
    },
    var.ssc_cbrid_tag_value != "" ? { (var.ssc_cbrid_tag_key) = var.ssc_cbrid_tag_value } : {}
  )
  gh_url  = "https://${local.gh_path}"
  gh_path = "token.actions.githubusercontent.com"

  # Normalize each role's subject claims into a single list of fully-qualified
  # `sub` values. This supports both the single `repo_name`/`claim` form and the
  # multi-entry `claims` list, so downstream resources only need to handle a list.
  role_subjects = {
    for r in var.roles : r.name => (
      length(r.claims) > 0 ?
      [for c in r.claims : "repo:${coalesce(c.org_name, var.org_name)}/${c.repo_name}:${c.claim}"] :
      ["repo:${var.org_name}/${r.repo_name}:${r.claim}"]
    )
  }
}

