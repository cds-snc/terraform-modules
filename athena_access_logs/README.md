# athena\_access\_logs
Creates an Athena database, work group and saved queries for examining WAF ACL and Load Balancer access logs.

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
| [aws_athena_database.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database) | resource |
| [aws_athena_named_query.lb_create_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.waf_all_requests](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.waf_blocked_requests](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.waf_create_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_workgroup.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_athena_bucket_name"></a> [athena\_bucket\_name](#input\_athena\_bucket\_name) | (Required) The name of the S3 bucket Athena will use to hold its data. | `string` | n/a | yes |
| <a name="input_athena_database_name"></a> [athena\_database\_name](#input\_athena\_database\_name) | (Optional, default `access_logs`) The name Athena database to create. | `string` | `"access_logs"` | no |
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | (Optional, default `logs`) The name Athena workgroup to create. | `string` | `"logs"` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default `CostCentre`) The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_lb_access_log_bucket_name"></a> [lb\_access\_log\_bucket\_name](#input\_lb\_access\_log\_bucket\_name) | (Optional, default `null`) S3 bucket name of the load balancer's access logs. | `string` | `null` | no |
| <a name="input_lb_access_queries_create"></a> [lb\_access\_queries\_create](#input\_lb\_access\_queries\_create) | (Optional, default `false`) Create the Athena queries for a load balancer's access logs.  If `true`, you must specify a value for `lb_access_log_bucket_name`. | `bool` | `false` | no |
| <a name="input_waf_access_log_bucket_name"></a> [waf\_access\_log\_bucket\_name](#input\_waf\_access\_log\_bucket\_name) | (Optional, default `null`) S3 bucket name of the WAF's access logs. | `string` | `null` | no |
| <a name="input_waf_access_queries_create"></a> [waf\_access\_queries\_create](#input\_waf\_access\_queries\_create) | (Optional, default `false`) Create the Athena queries for a WAF ACL's access logs.  If `true`, you must specify a value for `waf_access_log_bucket_name`. | `bool` | `false` | no |

## Outputs

No outputs.
