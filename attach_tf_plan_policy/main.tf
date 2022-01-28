/* # attach_tf_plan_policy
* This creates a policy that allows access to dynamodb, s3 state bucket
* and gives the ability to read secrets.
* 
* **Please Note:** This may too permissive for what you want to do so you might want to further lock it down.
*/

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.role_name
  policy_arn = resource.aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {

  statement {
    sid     = "AllowAllDynamoDBActionsOnAllTerragruntTables"
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.lock_table_name}"
    ]
  }

  statement {
    sid     = "AllowAllS3ActionsOnTerragruntBuckets"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

  statement {
    sid    = "AllowReadingSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:*"]
  }

  statement {
    sid       = "ListSecrets"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
}
