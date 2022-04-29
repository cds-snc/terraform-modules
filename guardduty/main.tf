/* # guardduty
* Adapted from https://github.com/aws-samples/amazon-guardduty-for-aws-organizations-with-terraform
*/

# GuardDuty Detector in the Delegated admin account
resource "aws_guardduty_detector" "this" {
  provider   = aws.guardduty_region
  depends_on = [var.organization_id]

  enable                       = true
  finding_publishing_frequency = var.publishing_frequency

  # Additional setting to turn on S3 Protection
  datasources {
    s3_logs {
      enable = true
    }
  }
  tags = merge(var.tags, local.common_tags)
}

# Organization GuardDuty configuration in the Management account
resource "aws_guardduty_organization_admin_account" "this" {
  provider = aws.management_region

  depends_on = [aws_guardduty_detector.this]

  admin_account_id = var.delegated_admin_account_id
}

# Organization GuardDuty configuration in the Delegated admin account
resource "aws_guardduty_organization_configuration" "this" {
  provider = aws.guarduty_region

  depends_on = [aws_guardduty_organization_admin_account.this]

  auto_enable = true
  detector_id = aws_guardduty_detector.this.id

  # Additional setting to turn on S3 Protection
  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

# GuardDuty Publishing destination in the Delegated admin account
resource "aws_guardduty_publishing_destination" "pub_dest" {
  provider   = aws.guardduty_region
  depends_on = [aws_guardduty_organization_admin_account.this]

  detector_id     = aws_guardduty_detector.this.id
  destination_arn = var.publishing_bucket_arn
  kms_key_arn     = var.kms_key_arn
}