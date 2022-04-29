/* # guardduty_member
* This is only needed for enrolling accounts to Guardduty that were created before Guarduty was enabled.
* New accounts will be auto-enrolled by default if it was configured or if our Guardduty module was used.
*/

data "aws_guardduty_detector" "this" {
  provider = aws.primary_role
}

data "aws_caller_identity" "member" {
  provider = aws.member_role
}

data "aws_caller_identity" "primary" {
  provider = aws.primary_role
}

# The guardduty delegated admin account is where the member is registered and invited from.
resource "aws_guardduty_member" "this" {
  provider = aws.primary_role

  detector_id = data.aws_guardduty_detector.this.id
  account_id  = data.aws_caller_identity.member.account_id
  invite      = true

  email                      = data.aws_caller_identity.member.account_email
  disable_email_notification = true

  lifecycle {
    ignore_changes = [
      email
    ]
  }
}

# Accepting the invite needs to occur in the member account
resource "aws_guardduty_invite_accepter" "this" {
  depends_on = [aws_guardduty_member.this]
  provider   = aws.member_role

  detector_id       = data.aws_guardduty_detector.this.id
  master_account_id = data.aws_caller_identity.primary.account_id
}