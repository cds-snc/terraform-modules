resource "aws_ecr_repository" "this" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = var.lambda_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.create_ecr_repository ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = file("${path.module}/ecr_lifecycle.json")
}
