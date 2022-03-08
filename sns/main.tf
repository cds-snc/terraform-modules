/* # SNS
*
*  A wrapper on the SNS module that enfores a customer managed KMS key
*
*/

data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "this" {
  name                                     = var.name
  name_prefix                              = var.name_prefix
  display_name                             = var.display_name
  policy                                   = var.policy
  delivery_policy                          = var.delivery_policy
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn
  http_success_feedback_role_arn           = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate        = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn           = var.http_failure_feedback_role_arn
  kms_master_key_id                        = var.kms_master_key_id == null ? aws_kms_key.sns_key[0].arn : var.kms_master_key_id
  fifo_topic                               = var.fifo_topic
  content_based_deduplication              = var.content_based_deduplication
  lambda_success_feedback_role_arn         = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn         = var.lambda_failure_feedback_role_arn
  sqs_success_feedback_role_arn            = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn            = var.sqs_failure_feedback_role_arn
  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn
  tags                                     = merge(local.common_tags, var.tags)
}



data "aws_iam_policy_document" "kms_policies" {
  dynamic "statement" {
    for_each = var.kms_event_sources

    content {
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = statement.value
      }

      actions = [
        "kms:Decrypt*",
        "kms:GenerateDataKey*",
      ]

      resources = [
        "*"
      ]

      condition {
        test     = "StringLike"
        variable = "AWS:SourceArn"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

  dynamic "statement" {
    for_each = var.kms_iam_sources

    content {
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = statement.value
      }

      actions = [
        "kms:Decrypt*",
        "kms:GenerateDataKey*",
      ]

      resources = [
        "*"
      ]

      condition {
        test     = "StringLike"
        variable = "AWS:SourceArn"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

}

resource "aws_kms_key" "sns_key" {
  count       = var.kms_master_key_id == null ? 1 : 0
  description = "SNS Key for ${var.name}"
  policy      = data.aws_iam_policy_document.kms_policies.statement == null ? null : data.aws_iam_policy_document.kms_policies.json
}