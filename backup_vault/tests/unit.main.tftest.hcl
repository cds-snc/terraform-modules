provider "aws" {
  region = "ca-central-1"
}

variables {
  name              = "test-backup-vault"
  billing_tag_value = "test"
}

run "vault_without_lock" {
  command = plan

  assert {
    condition     = aws_backup_vault.this.name == "test-backup-vault"
    error_message = "Backup vault name did not match expected value."
  }

  assert {
    condition     = aws_backup_vault.this.tags["CostCentre"] == "test"
    error_message = "Backup vault billing tag did not match expected value."
  }

  assert {
    condition     = length(aws_backup_vault_lock_configuration.this) == 0
    error_message = "Backup vault lock should not exist without lock configuration."
  }
}

run "vault_with_compliance_lock" {
  command = plan

  variables {
    min_retention_days  = 7
    max_retention_days  = 35
    changeable_for_days = 3
  }

  assert {
    condition     = length(aws_backup_vault_lock_configuration.this) == 1
    error_message = "Backup vault lock was not created."
  }

  assert {
    condition     = aws_backup_vault_lock_configuration.this[0].min_retention_days == 7
    error_message = "Backup vault minimum retention did not match expected value."
  }

  assert {
    condition     = aws_backup_vault_lock_configuration.this[0].max_retention_days == 35
    error_message = "Backup vault maximum retention did not match expected value."
  }

  assert {
    condition     = aws_backup_vault_lock_configuration.this[0].changeable_for_days == 3
    error_message = "Backup vault compliance-mode grace period did not match expected value."
  }
}

run "vault_with_customer_managed_kms_key" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:ca-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }

  assert {
    condition     = aws_backup_vault.this.kms_key_arn == "arn:aws:kms:ca-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    error_message = "Backup vault KMS key ARN did not match expected value."
  }

  assert {
    condition     = output.backup_vault_kms_key_arn == "arn:aws:kms:ca-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    error_message = "Backup vault KMS key ARN output did not match expected value."
  }
}

run "retention_bounds_are_valid" {
  command = plan

  variables {
    min_retention_days = 35
    max_retention_days = 7
  }

  expect_failures = [
    aws_backup_vault.this,
  ]
}

run "retention_period_cannot_exceed_three_years" {
  command = plan

  variables {
    max_retention_days = 1096
  }

  expect_failures = [
    var.max_retention_days,
  ]
}

run "minimum_retention_cannot_exceed_three_years" {
  command = plan

  variables {
    min_retention_days = 1096
  }

  expect_failures = [
    var.min_retention_days,
  ]
}