# WAF IP blocklist
This module creates a WAF IP blocklist that is automatically updated on a user-defined schedule.

The automatic update is based on a service's WAF and load balancer logs where an IP address exceeds the block threshold in a 24 hour period.

The IP block is temporary and the IP address will be removed once it has been at least 24 hours since it has exceeded
the block threshold.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.ip_added_to_block_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_iam_policy.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_wafv2_ip_set.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [archive_file.ipv4_blocklist](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.waf_ip_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_athena_database_name"></a> [athena\_database\_name](#input\_athena\_database\_name) | (Optional, default 'access\_logs') The name of the Athena database where the WAF logs table exists. | `string` | `"access_logs"` | no |
| <a name="input_athena_lb_table_name"></a> [athena\_lb\_table\_name](#input\_athena\_lb\_table\_name) | (Optional, default 'lb\_logs') The name of the Load Balancer logs table in the Athena database. | `string` | `"lb_logs"` | no |
| <a name="input_athena_query_results_bucket"></a> [athena\_query\_results\_bucket](#input\_athena\_query\_results\_bucket) | (Required) The name of the S3 bucket where the Athena query results are stored. | `string` | n/a | yes |
| <a name="input_athena_query_source_bucket"></a> [athena\_query\_source\_bucket](#input\_athena\_query\_source\_bucket) | (Required) The name of the S3 bucket where the source data for the Athena query lives. | `string` | n/a | yes |
| <a name="input_athena_waf_table_name"></a> [athena\_waf\_table\_name](#input\_athena\_waf\_table\_name) | (Optional, default 'waf\_logs') The name of the WAF logs table in the Athena database. | `string` | `"waf_logs"` | no |
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | (Optional, default 'primary') The name of the Athena workgroup. | `string` | `"primary"` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_query_lb"></a> [query\_lb](#input\_query\_lb) | (Optional, default true) Should the Load Balancer logs be queried for 4xx responses? | `bool` | `true` | no |
| <a name="input_query_waf"></a> [query\_waf](#input\_query\_waf) | (Optional, default true) Should the WAF logs be queried for BLOCK responses? | `bool` | `true` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | (Required) The name of the service | `string` | n/a | yes |
| <a name="input_waf_block_threshold"></a> [waf\_block\_threshold](#input\_waf\_block\_threshold) | (Optional, default 20) The threshold of blocked requests for adding an IP address to the blocklist | `number` | `20` | no |
| <a name="input_waf_ip_blocklist_update_schedule"></a> [waf\_ip\_blocklist\_update\_schedule](#input\_waf\_ip\_blocklist\_update\_schedule) | (Optional, default 'rate(2 hours)') The schedule expression for updating the WAF IP blocklist | `string` | `"rate(2 hours)"` | no |
| <a name="input_waf_rule_ids_skip"></a> [waf\_rule\_ids\_skip](#input\_waf\_rule\_ids\_skip) | (Optional, default []) A list of WAF rule IDs to ignore when adding an IP address to the blocklist | `list(string)` | `[]` | no |
| <a name="input_waf_scope"></a> [waf\_scope](#input\_waf\_scope) | (Optional, default 'REGIONAL') The scope of the WAF IP blocklist | `string` | `"REGIONAL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4_blocklist_arn"></a> [ipv4\_blocklist\_arn](#output\_ipv4\_blocklist\_arn) | The ARN of the IP blocklist |
| <a name="output_ipv4_lambda_cloudwatch_log_group_arn"></a> [ipv4\_lambda\_cloudwatch\_log\_group\_arn](#output\_ipv4\_lambda\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch Log Group for the IPv4 blocklist Lambda |
| <a name="output_ipv4_lambda_cloudwatch_log_group_name"></a> [ipv4\_lambda\_cloudwatch\_log\_group\_name](#output\_ipv4\_lambda\_cloudwatch\_log\_group\_name) | The name of the CloudWatch Log Group for the IPv4 blocklist Lambda |
| <a name="output_ipv4_new_blocked_ip_metric_filter_name"></a> [ipv4\_new\_blocked\_ip\_metric\_filter\_name](#output\_ipv4\_new\_blocked\_ip\_metric\_filter\_name) | The metric filter name for the number of new blocked IPs |
| <a name="output_ipv4_new_blocked_ip_metric_filter_namespace"></a> [ipv4\_new\_blocked\_ip\_metric\_filter\_namespace](#output\_ipv4\_new\_blocked\_ip\_metric\_filter\_namespace) | The metric filter namespace for the number of new blocked IPs |
