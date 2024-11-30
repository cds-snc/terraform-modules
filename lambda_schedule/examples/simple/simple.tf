module "simple" {
  source = "../../"

  lambda_name                = "simple-test"
  lambda_schedule_expression = "rate(1 day)"

  lambda_environment_variables = {
    VAR1 = "value1"
    VAR2 = "value2"
  }

  billing_tag_value = "Test"
}
