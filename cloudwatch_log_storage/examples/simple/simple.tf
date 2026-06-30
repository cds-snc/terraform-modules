
module "simple" {
  source = "../../"

  product_name               = "simple"
  cloudwatch_log_group_names = ["/aws/lambda/my-function"]

  billing_tag_value = "Terratest"
}

