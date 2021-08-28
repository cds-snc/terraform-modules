
###
# Common tags
###
variable "billing_tag_key" {
  description = "(Optional) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

variable "name" {
  type        = string
  description = "(required) Name of the Monolith"
}

variable "lambda_arn" {
  type        = string
  description = "(required) The arn of the lambda that runs the monolith"
}
