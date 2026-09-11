# Sentinel forwarder

This module sets up a lambda that will forward AWS logs to Azure Sentinel.
It is a light wrapper on the code found here (https://github.com/cds-snc/aws-sentinel-connector-layer) and
just stitches together the code with the triggers.

Triggers can be EventHub rules, S3 ObjectCreated events, or CloudWatch Log Subscriptions. The following log types are supported:
- CloudTrail (.json.gz)
- Load balancer (.log.gz)
- VPC flow logs (.log.gz)
- WAF ACL (.gz)
- GuardDuty
- SecurityHub (via EventHub)
- Generic application json logs

The layer carries two Azure APIs and picks between them per Lambda, on the presence of the environment variables this
module sets. Which one you get is decided by which inputs you supply:

* **v1, the Data Collector API.** Set `customer_id` and `shared_key`. They are held in an SSM `SecureString` and loaded
  at cold start. Data lands in the legacy `*_CL` tables.
* **v2, the Logs Ingestion API.** Set `dce_endpoint` and `dcr_config` — both, or the layer stays on v1 — plus
  `azure_client_id` and `azure_tenant_id`. Data lands in the tables behind those DCRs.

v2 then takes one of two auth paths. Supplying `azure_client_secret` selects the client-secret path and takes
precedence. Supplying `cognito_identity_pool_id` and `cognito_developer_provider_name` instead selects the secretless
path: this module grants the Lambda `cognito-identity:GetOpenIdTokenForDeveloperIdentity` on that pool, the layer
exchanges the resulting OIDC token for an Entra token as a user-assigned managed identity, and nothing is stored
anywhere. The identity pool must be in this Lambda's own AWS account — identity pools have no resource policy, so one
cannot be called cross-account.

A caller that sets none of the v2 inputs is on v1 and behaves exactly as it did before they existed.

AWS logs are automatically assigned a LogType. Custom application logs are given the log type defined through
`var.log_type`, which applies on v1 only — under v2 the destination comes from `dcr_config`. They also need to be
nested inside a json object with the key, `application_log`. ex: `{'application_log': {'foo': 'bar'}}` for the layer
code to forward it to Azure Sentinel.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.46.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_target.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sentinel_forwarder_cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.sentinel_forwarder_cloudwatch_log_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sentinel_forwarder_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sentinel_forwarder_s3_triggers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.sentinel_forwarder_trigger_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_ssm_parameter.sentinel_forwarder_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [archive_file.sentinel_forwarder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sentinel_forwarder_cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sentinel_forwarder_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sentinel_forwarder_lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | (Optional, v2) Client ID of the Azure identity the forwarder authenticates as. Required on both v2 auth paths. | `string` | `""` | no |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | (Optional, v2) Client secret for the Azure identity. Supplying one selects the client-secret auth path and takes precedence over Cognito federation; leave it unset for the secretless path. | `string` | `""` | no |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | (Optional, v2) Azure tenant ID of that identity. Required on both v2 auth paths. | `string` | `""` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_log_arns"></a> [cloudwatch\_log\_arns](#input\_cloudwatch\_log\_arns) | (Optional) A list of CloudWatch log ARNs to forward to Sentinel | `list(string)` | `[]` | no |
| <a name="input_cognito_developer_provider_name"></a> [cognito\_developer\_provider\_name](#input\_cognito\_developer\_provider\_name) | (Optional, v2) Developer provider name on that identity pool. Set with `cognito_identity_pool_id`. | `string` | `""` | no |
| <a name="input_cognito_identity_pool_id"></a> [cognito\_identity\_pool\_id](#input\_cognito\_identity\_pool\_id) | (Optional, v2) Cognito identity pool that mints the OIDC assertion, in this Lambda's own AWS account. Set with `cognito_developer_provider_name` for the secretless auth path. | `string` | `""` | no |
| <a name="input_customer_id"></a> [customer\_id](#input\_customer\_id) | (Optional, v1 only) Azure log workspace customer ID. Required on the v1 Data Collector API path; leave unset on v2, which authenticates as an Azure identity instead. | `string` | `""` | no |
| <a name="input_dce_endpoint"></a> [dce\_endpoint](#input\_dce\_endpoint) | (Optional, v2) Logs ingestion endpoint of the Azure data collection endpoint. Set together with `dcr_config` to put this forwarder on the Logs Ingestion API; leave both unset to stay on the v1 Data Collector API. | `string` | `""` | no |
| <a name="input_dcr_config"></a> [dcr\_config](#input\_dcr\_config) | (Optional, v2) Map of the layer's log type to the DCR that accepts it. Feed the `forwarder_v2_aws_dcr_config` output from cds-snc/sentinel verbatim — the attribute names are what the layer reads. | <pre>map(object({<br/>    dcrImmutableId = string<br/>    streamName     = string<br/>  }))</pre> | `{}` | no |
| <a name="input_event_rule_names"></a> [event\_rule\_names](#input\_event\_rule\_names) | (Optional) List of names for event rules to trigger the lambda | `list(string)` | `[]` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | (Required) Name of the Lambda function. | `string` | n/a | yes |
| <a name="input_layer_arn"></a> [layer\_arn](#input\_layer\_arn) | (Optional) ARN of the lambda layer to use | `string` | `"arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:20"` | no |
| <a name="input_log_type"></a> [log\_type](#input\_log\_type) | (Optional) The namespace for logs. This only applies if you are sending application logs | `string` | `"ApplicationLog"` | no |
| <a name="input_s3_sources"></a> [s3\_sources](#input\_s3\_sources) | (Optional) List of s3 buckets to trigger the lambda | <pre>list(object({<br/>    bucket_arn    = string<br/>    bucket_id     = string<br/>    filter_prefix = string<br/>    kms_key_arn   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_shared_key"></a> [shared\_key](#input\_shared\_key) | (Optional, v1 only) Azure log workspace shared secret. Required on the v1 Data Collector API path; leave unset on v2. | `string` | `""` | no |
| <a name="input_ssc_cbrid_tag_key"></a> [ssc\_cbrid\_tag\_key](#input\_ssc\_cbrid\_tag\_key) | (Optional, default 'ssc\_cbrid') The tag key for the SSC CBRID | `string` | `"ssc_cbrid"` | no |
| <a name="input_ssc_cbrid_tag_value"></a> [ssc\_cbrid\_tag\_value](#input\_ssc\_cbrid\_tag\_value) | (Optional) The value of the SSC CBRID tag | `string` | `"22DH"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | The ARN of the Lambda function. |
| <a name="output_lambda_environment_keys"></a> [lambda\_environment\_keys](#output\_lambda\_environment\_keys) | Sorted names of the environment variables set on the Lambda. `DCE_ENDPOINT` and `DCR_CONFIG` appearing here means this forwarder is on the Logs Ingestion API. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | The name of the Lambda function. |
