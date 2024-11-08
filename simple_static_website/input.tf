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

variable "lambda_function_association" {
  description = "(Optional) Map containing lambda function association configuration. A maximum of 4 can be specified."
  type        = list(map(string))
  default     = []
  validation {
    condition     = length(var.lambda_function_association) <= 4
    error_message = "No more than 4 lambda function associations can be specified."
  }
}

variable "function_association" {
  description = "(Optional) Map containing function association configuration, that trigers a cloudfront function with specific actions. A maximum of 2 can be specified."
  type        = list(map(string))
  default     = []
  validation {
    condition     = length(var.function_association) <= 2
    error_message = "No more than 2 function associations can be specified."
  }
}

variable "s3_bucket_name" {
  description = "(Optional, default '') Name of the S3 bucket.  If not specified the domain_name_source + a random number will be used."
  type        = string
  default     = ""
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

variable "is_create_certificate" {
  description = "(Optional, default 'true') Should the ACM certificate be created by the module?  If false, a certificate with the specified acm_certificate_arn must exist."
  type        = bool
  default     = true
}


variable "is_create_hosted_zone" {
  description = "(Optional, default 'true') Should the hosted zone be created by the module?  If false, a hosted zone with the specified hosted_zone_id must exist."
  type        = bool
  default     = true
}


variable "index_document" {
  description = "(Optional, default 'index.html') The name of the index document."
  type        = string
  default     = "index.html"
}

variable "single_page_app" {
  description = "(Optional, default 'false') If true, the index document will be returned for all 403 requests to the origin."
  type        = bool
  default     = false
}

variable "cloudfront_query_string_forwarding" {
  description = "(Optional, default 'false') If true, query strings will be forwarded to the origin."
  type        = bool
  default     = false
}

variable "force_destroy_s3_bucket" {
  description = "(Optional, default 'false') If true, the s3 bucket will be deleted even if it's full. Not advised for production use."
  type        = bool
  default     = false
}

variable "web_acl_arn" {
  description = "(Optional, default null) ARN of the WAF Web ACL to associate with the CloudFront distribution (using version WAFv2)."
  type        = string
  default     = null
}

variable "custom_error_responses" {
  description = "(Optional) Map containing custom error responses.  The key is the HTTP error code and the value is the response page."
  type = list(object({
    error_code            = number
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  response_code = optional(number) }))
  default = []
}
