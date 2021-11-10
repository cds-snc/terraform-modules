### Policies from consumer
resource "aws_iam_policy" "policies" {
  count  = length(var.policies)
  name   = "${var.name}-${count.index}"
  path   = "/"
  policy = var.policies[count.index]
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = length(aws_iam_policy.policies.*.arn)
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.policies[count.index].arn
}