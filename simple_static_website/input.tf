variable "acm_certificate_arn" {
  description = "(Optional, default '') ARN of the us-east-1 region certificate used by CloudFront.  If not specified, a new certificate will be created."
  type        = string
  default     = ""
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag."
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag."
  type        = string
}

variable "cloudfront_price_class" {
  description = "(Optional, default 'PriceClass_100') The price class of the CloudFront distribution."
  type        = string
  default     = "PriceClass_100"
}

variable "domain_name_source" {
  description = "(Required) Domain name that will be initially entered by the user. It should be in the form 'example.com'."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+([\\-\\.]{1}[a-z0-9]+)*\\.[a-z]{2,}$", lower(var.domain_name_source)))
    error_message = "The domain name is not valid. It should be in the form 'example.com'."
  }
}

variable "error_document" {
  description = "(Optional, default 'error.html') The name of the error document."
  type        = string
  default     = "error.html"
}

variable "hosted_zone_id" {
  description = "(Optional, default '') Hosted zone ID used to create the domain name source ALIAS record pointing to Cloudfront.  If not specified, a new hosted zone will be created."
  type        = string
  default     = ""
}

variable "index_document" {
  description = "(Optional, default 'index.html') The name of the index document."
  type        = string
  default     = "index.html"
}
