#
# IAM role to allow replication
#
resource "aws_iam_role" "replication" {
  name               = "s3-bucket-replication-${random_pet.this.id}"
  assume_role_policy = data.aws_iam_policy_document.s3_assume.json
}

resource "aws_iam_policy" "replication" {
  name   = "s3-bucket-replication-${random_pet.this.id}"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "s3-bucket-replication-${random_pet.this.id}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}

data "aws_iam_policy_document" "s3_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [
      module.source_bucket.s3_bucket_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl"
    ]
    resources = [
      "${module.source_bucket.s3_bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = [
      "${module.destination_bucket.s3_bucket_arn}/*"
    ]
  }
}




