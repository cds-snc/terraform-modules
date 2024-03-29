# S3\_scan\_object
Trigger [ClamAV scans](https://scan-files.alpha.canada.ca) of newly created S3 objects and updates the object with the scan results.  The S3 events are sent to an SQS queue where they are processed by the Scan Files API.

## ⚠️ Notes
- To use the default values for the following variables, your account must be part of our AWS organization:
   - `scan_files_role_arn`
   - `s3_scan_object_role_arn`
- You can build your own Lambda Docker image using the code in [cds-snc/scan-files/module/s3-scan-object](https://github.com/cds-snc/scan-files/tree/main/module/s3-scan-object).

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.s3_scan_object_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.s3_scan_object_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket_notification.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.upload_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_sqs_queue.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.limit_tagging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_scan_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_scan_object_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scan_files_download](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.upload_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.scan_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_s3_scan_object_role_arn"></a> [s3\_scan\_object\_role\_arn](#input\_s3\_scan\_object\_role\_arn) | (Optional, default S3 Scan Object role) S3 scan object lambda execution role ARN | `string` | `"arn:aws:iam::806545929748:role/s3-scan-object"` | no |
| <a name="input_s3_upload_bucket_names"></a> [s3\_upload\_bucket\_names](#input\_s3\_upload\_bucket\_names) | (Required) Names of the existing S3 upload bucket to scan objects in. | `list(string)` | n/a | yes |
| <a name="input_s3_upload_bucket_policy_create"></a> [s3\_upload\_bucket\_policy\_create](#input\_s3\_upload\_bucket\_policy\_create) | (Optional, defaut 'true') Create the S3 upload bucket policy to allow Scan Files access. | `bool` | `true` | no |
| <a name="input_scan_files_assume_role_create"></a> [scan\_files\_assume\_role\_create](#input\_scan\_files\_assume\_role\_create) | (Optional, default 'true') Create the IAM role that Scan Files assumes.  Defaults to `true`.  If this is set to `false`, it is assumed that the role already exists in the account. | `bool` | `true` | no |
| <a name="input_scan_files_role_arn"></a> [scan\_files\_role\_arn](#input\_scan\_files\_role\_arn) | (Optional, default Scan Files API role) Scan Files lambda execution role ARN | `string` | `"arn:aws:iam::806545929748:role/scan-files-api"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scan_files_assume_role_arn"></a> [scan\_files\_assume\_role\_arn](#output\_scan\_files\_assume\_role\_arn) | ARN of the role assumed by the Scan Files API |
