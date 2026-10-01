/* # AWS Backup Vault
* This module creates an AWS Backup vault using the AWS Backup managed key by default.
* A caller may provide a customer-managed KMS key for an Aurora cross-Region copy destination vault.
*/

resource "aws_backup_vault" "this" {
  name        = var.name
  kms_key_arn = var.kms_key_arn
  tags        = local.common_tags

  lifecycle {
    precondition {
      condition     = var.min_retention_days == null ? true : (var.max_retention_days == null ? true : var.min_retention_days <= var.max_retention_days)
      error_message = "min_retention_days cannot be greater than max_retention_days."
    }
  }
}

resource "aws_backup_vault_lock_configuration" "this" {
  count = local.vault_lock_enabled ? 1 : 0

  backup_vault_name   = aws_backup_vault.this.name
  min_retention_days  = var.min_retention_days
  max_retention_days  = var.max_retention_days
  changeable_for_days = var.changeable_for_days
}