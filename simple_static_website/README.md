# Simple static website
The purpose of this module is to create a simple static website using S3 and CloudFront.
Access to the S3 bucket is restricted to CloudFront using an Origin Access Identity (OAI).

## Usage
```
module "website" {
 source  = "github.com/cds-snc/terraform-modules//simple_static_website"

 domain_name_source = "example.com"
 billing_tag_value  = "simple-static-website"

 providers = {
   aws           = aws
   aws.dns       = aws.dns # For scenarios where there is a dedicated DNS provider.  You can also just use the default.
   aws.us-east-1 = aws.us-east-1
 }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9 |
| <a name="provider_aws.dns"></a> [aws.dns](#provider\_aws.dns) | >= 4.9 |
| <a name="provider_aws.us-east-1"></a> [aws.us-east-1](#provider\_aws.us-east-1) | >= 4.9 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.simple_static_website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.simple_static_website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.cloudfront_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront_certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.oai_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | (Optional, default '') ARN of the us-east-1 region certificate used by CloudFront.  If not specified, a new certificate will be created. | `string` | `""` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag. | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag. | `string` | n/a | yes |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | (Optional, default 'PriceClass\_100') The price class of the CloudFront distribution. | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_query_string_forwarding"></a> [cloudfront\_query\_string\_forwarding](#input\_cloudfront\_query\_string\_forwarding) | (Optional, default 'false') If true, query strings will be forwarded to the origin. | `bool` | `false` | no |
| <a name="input_domain_name_source"></a> [domain\_name\_source](#input\_domain\_name\_source) | (Required) Domain name that will be initially entered by the user. It should be in the form 'example.com'. | `string` | n/a | yes |
| <a name="input_error_document"></a> [error\_document](#input\_error\_document) | (Optional, default 'error.html') The name of the error document. | `string` | `"error.html"` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | (Optional, default '') Hosted zone ID used to create the domain name source ALIAS record pointing to Cloudfront.  If not specified, a new hosted zone will be created. | `string` | `""` | no |
| <a name="input_index_document"></a> [index\_document](#input\_index\_document) | (Optional, default 'index.html') The name of the index document. | `string` | `"index.html"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | (Optional, default '') Name of the S3 bucket.  If not specified the domain\_name\_source + a random number will be used. | `string` | `""` | no |
| <a name="input_single_page_app"></a> [single\_page\_app](#input\_single\_page\_app) | (Optional, default 'false') If true, the index document will be returned for all 403 requests to the origin. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this bucket resides in. |
