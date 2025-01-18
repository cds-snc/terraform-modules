/* 
* # Lambda schedule
*
* Runs a Lambda function on a schedule using an AWS CloudWatch event rule.
*
* :warning: If you have the module create the ECR (default behaviour), the first apply of this module will fail until a `latest` tagged Docker image has been pushed to the ECR (:chicken: vs :egg:).
*/

module "this_lambda" {
  source = "github.com/cds-snc/terraform-modules//lambda?ref=v10.2.2"

  name      = var.lambda_name
  image_uri = local.lambda_image_uri
  ecr_arn   = local.lambda_ecr_arn

  timeout               = var.lambda_timeout
  memory                = var.lambda_memory
  environment_variables = var.lambda_environment_variables
  vpc                   = var.lambda_vpc_config
  policies              = local.policies

  billing_tag_key   = var.billing_tag_key
  billing_tag_value = var.billing_tag_value
}

# Allow write to the specified S3 bucket path
data "aws_iam_policy_document" "s3_write" {
  count = var.s3_arn_write_path != null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      var.s3_arn_write_path,
    ]
  }
}

#
# Trigger the function at a given rate
#
resource "aws_cloudwatch_event_rule" "this" {
  name                = "${var.lambda_name}-schedule"
  description         = "Triggers Lambda ${var.lambda_name} on a schedule"
  schedule_expression = var.lambda_schedule_expression
  tags                = local.common_tags
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = module.this_lambda.function_arn
  target_id = var.lambda_name
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromEventBridge-${var.lambda_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
