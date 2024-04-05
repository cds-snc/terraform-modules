data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  common_tags = {
    Terraform  = "true"
    CostCentre = var.billing_tag_value
  }
  database_kinesis_stream_arn = "arn:aws:kinesis:${local.region}:${local.account_id}:stream/${aws_rds_cluster_activity_stream.activity_stream.kinesis_stream_name}"
  decrypt_lambda_function     = "${var.rds_stream_name}-decrypt-activity-stream"
  python_version              = "python3.12"
  region                      = data.aws_region.current.name
}
