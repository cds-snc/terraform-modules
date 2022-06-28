# S3\_scan\_object
Lambda function that triggers a [scan](https://scan-files.alpha.canada.ca) of newly created S3 objects and updates the object with the scan results via an SNS topic subscription.

The function is invoked by `s3:ObjectCreated:*` events and messages published to its SNS `s3-object-scan-complete` topic.

## ⚠️ Notes
- You will need a Scan Files API key to use this module.
- Your AWS account must be part of our organization to use the default `lambda_ecr_arn` and `lambda_image_uri`.  To work around this, you can build your own Docker image using the code in [cds-snc/scan-files/module/s3-scan-object](https://github.com/cds-snc/scan-files/tree/main/module/s3-scan-object).

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_scan_object"></a> [s3\_scan\_object](#module\_s3\_scan\_object) | github.com/cds-snc/terraform-modules | v3.0.2//lambda |
| <a name="module_upload_bucket"></a> [upload\_bucket](#module\_upload\_bucket) | github.com/cds-snc/terraform-modules | v2.0.5//S3 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.sns_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_permission.s3_execute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.scan_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.upload_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_sns_topic.scan_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.scan_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.scan_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_ssm_parameter.scan_files_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.limit_tagging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files_download](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.upload_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_lambda_ecr_arn"></a> [lambda\_ecr\_arn](#input\_lambda\_ecr\_arn) | (Optional, default Scan Files ECR) ARN of the ECR used to pull the Lambda image | `string` | `"arn:aws:ecr:ca-central-1:806545929748:scan-files/module/s3-scan-object"` | no |
| <a name="input_lambda_image_uri"></a> [lambda\_image\_uri](#input\_lambda\_image\_uri) | (Optional, default Scan Files ECR latest Docker image) The URI of the Lambda image | `string` | `"806545929748.dkr.ecr.ca-central-1.amazonaws.com/scan-files/module/s3-scan-object:7951f8348856c5712ec3ec4ef071717742062709"` | no |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Name of the product using the module | `string` | n/a | yes |
| <a name="input_s3_upload_bucket_create"></a> [s3\_upload\_bucket\_create](#input\_s3\_upload\_bucket\_create) | (Optional, default 'true') Create an S3 bucket to upload files to. | `bool` | `true` | no |
| <a name="input_s3_upload_bucket_name"></a> [s3\_upload\_bucket\_name](#input\_s3\_upload\_bucket\_name) | (Optional, default null) Name of the S3 upload bucket to scan objects in.  If `s3_upload_bucket_create` is `false` this must be an existing bucket in the account. | `string` | `null` | no |
| <a name="input_s3_upload_bucket_policy_create"></a> [s3\_upload\_bucket\_policy\_create](#input\_s3\_upload\_bucket\_policy\_create) | (Optional, defaut 'true') Create the S3 upload bucket policy to allow Scan Files access. | `bool` | `true` | no |
| <a name="input_scan_files_api_key"></a> [scan\_files\_api\_key](#input\_scan\_files\_api\_key) | (Required) Scan Files API key | `string` | n/a | yes |
| <a name="input_scan_files_assume_role_create"></a> [scan\_files\_assume\_role\_create](#input\_scan\_files\_assume\_role\_create) | (Optional, default 'true') Create the IAM role that Scan Files assumes.  Defaults to `true`.  If this is set to `false`, it is assumed that the role already exists in the account. | `bool` | `true` | no |
| <a name="input_scan_files_role_arn"></a> [scan\_files\_role\_arn](#input\_scan\_files\_role\_arn) | (Optional, Scan Files API role) Scan Files lambda execution role ARN | `string` | `"arn:aws:iam::806545929748:role/scan-files-api"` | no |
| <a name="input_scan_files_url"></a> [scan\_files\_url](#input\_scan\_files\_url) | (Optional, Scan Files production URL) Scan Files URL | `string` | `"https://scan-files.alpha.canada.ca"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the S3 scan object lambda role |
| <a name="output_s3_upload_bucket_arn"></a> [s3\_upload\_bucket\_arn](#output\_s3\_upload\_bucket\_arn) | ARN of the S3 upload bucket |
| <a name="output_s3_upload_bucket_name"></a> [s3\_upload\_bucket\_name](#output\_s3\_upload\_bucket\_name) | Name of the S3 upload bucket |
| <a name="output_scan_files_assume_role_arn"></a> [scan\_files\_assume\_role\_arn](#output\_scan\_files\_assume\_role\_arn) | ARN of the role assumed by the Scan Files API |
