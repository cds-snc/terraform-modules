# CDS Conformance Pack

This module creates a conformance pack for CDS based on the CCCS conformance pack found here: https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CCCS-Medium.yaml

It uses the same default inputs for terraform as specified in the CCCS conformance pack YAML, but can easily be overridden. Because a cloudformation template can only be 50kb in size when it is created over the wire, we need to create a bucket and upload the conformance pack to it. This module creates a bucket and uploads the conformance pack to it. The name of the bucket is based on the pattern `cds-conformance-pack-<random-uuid>`.

For example to meet the config rule `internet-gateway-authorized-vpc-only` you can set the authorized vpcs as follows:

```hcl
module "conformance_pack" {
  source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
  internet_gateway_authorized_vpc_only_param_authorized_vpc_ids = "vpc-00534274da4ade29d"
  billing_tag_value                                             = var.billing_code
}
```

To exclude specific rules from the conformance pack, you can use the `excluded_rules` variable. For example, to exclude the `internet-gateway-authorized-vpc-only` rule, you can set the variable as follows:

```hcl
module "conformance_pack" {
  source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
  excluded_rules                                                = ["InternetGatewayAuthorizedVpcOnly"]
  billing_tag_value                                             = var.billing_code
}
```

Note: The rules need to be in the CamelCase format as found in the YAML.

If you would like to append or override the default conformance pack, you can use the `custom_conformance_pack_path` variable. For example, to append a rule to the conformance pack, you can set the variable as follows:

```hcl
module "conformance_pack" {
  source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
  custom_conformance_pack_path                                  = "./custom_conformance_pack.yaml"
  billing_tag_value                                             = var.billing_code
}
```
The custom conformance pack should be in the same format as the CCCS conformance pack YAML, in that you can use a `Parameters`, `Resources`, and `Conditions` section.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3"></a> [s3](#module\_s3) | github.com/cds-snc/terraform-modules//S3 | v9.6.8 |

## Resources

| Name | Type |
|------|------|
| [aws_config_conformance_pack.cds_conformance_pack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_s3_object.conformace_pack_yaml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_uuid.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_keys_rotated_param_max_access_key_age"></a> [access\_keys\_rotated\_param\_max\_access\_key\_age](#input\_access\_keys\_rotated\_param\_max\_access\_key\_age) | (Optional) The maximum age in days before an access key must be rotated. | `string` | `"90"` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_cloudwatch_alarm_action_check_param_alarm_action_required"></a> [cloudwatch\_alarm\_action\_check\_param\_alarm\_action\_required](#input\_cloudwatch\_alarm\_action\_check\_param\_alarm\_action\_required) | (Optional) Indicates whether an action is required when the alarm changes to the ALARM state. | `string` | `"true"` | no |
| <a name="input_cloudwatch_alarm_action_check_param_insufficient_data_action_required"></a> [cloudwatch\_alarm\_action\_check\_param\_insufficient\_data\_action\_required](#input\_cloudwatch\_alarm\_action\_check\_param\_insufficient\_data\_action\_required) | (Optional) Indicates whether an action is required when the alarm changes to the INSUFFICIENT\_DATA state. | `string` | `"true"` | no |
| <a name="input_cloudwatch_alarm_action_check_param_ok_action_required"></a> [cloudwatch\_alarm\_action\_check\_param\_ok\_action\_required](#input\_cloudwatch\_alarm\_action\_check\_param\_ok\_action\_required) | (Optional) Indicates whether an action is required when the alarm changes to the OK state. | `string` | `"false"` | no |
| <a name="input_conformance_pack_name"></a> [conformance\_pack\_name](#input\_conformance\_pack\_name) | (Optional) The name of the conformance pack. | `string` | `"CDS-Conformance-Pack"` | no |
| <a name="input_custom_conformance_pack_path"></a> [custom\_conformance\_pack\_path](#input\_custom\_conformance\_pack\_path) | (Optional) The path to the custom conformance pack YAML file. | `string` | `""` | no |
| <a name="input_elb_predefined_security_policy_ssl_check_param_predefined_policy_name"></a> [elb\_predefined\_security\_policy\_ssl\_check\_param\_predefined\_policy\_name](#input\_elb\_predefined\_security\_policy\_ssl\_check\_param\_predefined\_policy\_name) | (Optional) The name of the predefined security policy for the ELB SSL negotiation configuration. | `string` | `"TLS-1-2-2017-01"` | no |
| <a name="input_excluded_rules"></a> [excluded\_rules](#input\_excluded\_rules) | (Optional) The list of rules to exclude from the conformance pack. These need to be in the CamelCase format as found in the YAML. | `list(string)` | `[]` | no |
| <a name="input_iam_customer_policy_blocked_kms_actions_param_blocked_actions_patterns"></a> [iam\_customer\_policy\_blocked\_kms\_actions\_param\_blocked\_actions\_patterns](#input\_iam\_customer\_policy\_blocked\_kms\_actions\_param\_blocked\_actions\_patterns) | (Optional) The patterns of KMS actions to be blocked in the customer-managed IAM policy. | `string` | `"kms:*, kms:Decrypt, kms:ReEncrypt*"` | no |
| <a name="input_iam_inline_policy_blocked_kms_actions_param_blocked_actions_patterns"></a> [iam\_inline\_policy\_blocked\_kms\_actions\_param\_blocked\_actions\_patterns](#input\_iam\_inline\_policy\_blocked\_kms\_actions\_param\_blocked\_actions\_patterns) | (Optional) The patterns of KMS actions to be blocked in the inline IAM policy. | `string` | `"kms:*, kms:Decrypt, kms:ReEncrypt*"` | no |
| <a name="input_iam_password_policy_param_max_password_age"></a> [iam\_password\_policy\_param\_max\_password\_age](#input\_iam\_password\_policy\_param\_max\_password\_age) | (Optional) The maximum password age in days for IAM users. | `string` | `"90"` | no |
| <a name="input_iam_password_policy_param_minimum_password_length"></a> [iam\_password\_policy\_param\_minimum\_password\_length](#input\_iam\_password\_policy\_param\_minimum\_password\_length) | (Optional) The minimum length for IAM user passwords. | `string` | `"14"` | no |
| <a name="input_iam_password_policy_param_password_reuse_prevention"></a> [iam\_password\_policy\_param\_password\_reuse\_prevention](#input\_iam\_password\_policy\_param\_password\_reuse\_prevention) | (Optional) The number of previous passwords that IAM users are prevented from reusing. | `string` | `"24"` | no |
| <a name="input_iam_password_policy_param_require_lowercase_characters"></a> [iam\_password\_policy\_param\_require\_lowercase\_characters](#input\_iam\_password\_policy\_param\_require\_lowercase\_characters) | (Optional) Indicates whether IAM user passwords must contain at least one lowercase letter. | `string` | `"true"` | no |
| <a name="input_iam_password_policy_param_require_numbers"></a> [iam\_password\_policy\_param\_require\_numbers](#input\_iam\_password\_policy\_param\_require\_numbers) | (Optional) Indicates whether IAM user passwords must contain at least one number. | `string` | `"true"` | no |
| <a name="input_iam_password_policy_param_require_symbols"></a> [iam\_password\_policy\_param\_require\_symbols](#input\_iam\_password\_policy\_param\_require\_symbols) | (Optional) Indicates whether IAM user passwords must contain at least one symbol. | `string` | `"true"` | no |
| <a name="input_iam_password_policy_param_require_uppercase_characters"></a> [iam\_password\_policy\_param\_require\_uppercase\_characters](#input\_iam\_password\_policy\_param\_require\_uppercase\_characters) | (Optional) Indicates whether IAM user passwords must contain at least one uppercase letter. | `string` | `"true"` | no |
| <a name="input_iam_user_unused_credentials_check_param_max_credential_usage_age"></a> [iam\_user\_unused\_credentials\_check\_param\_max\_credential\_usage\_age](#input\_iam\_user\_unused\_credentials\_check\_param\_max\_credential\_usage\_age) | (Optional) The maximum age in days for IAM user credentials that have not been used. | `string` | `"90"` | no |
| <a name="input_internet_gateway_authorized_vpc_only_param_authorized_vpc_ids"></a> [internet\_gateway\_authorized\_vpc\_only\_param\_authorized\_vpc\_ids](#input\_internet\_gateway\_authorized\_vpc\_only\_param\_authorized\_vpc\_ids) | (Optional) Comma-separated list of authorized VPC IDs that are allowed to use the Internet Gateway | `string` | `"here add Comma-separated list of the authorized VPC IDs"` | no |
| <a name="input_redshift_cluster_configuration_check_param_cluster_db_encrypted"></a> [redshift\_cluster\_configuration\_check\_param\_cluster\_db\_encrypted](#input\_redshift\_cluster\_configuration\_check\_param\_cluster\_db\_encrypted) | (Optional) Boolean value indicating whether the Redshift cluster's database is encrypted | `string` | `"true"` | no |
| <a name="input_redshift_cluster_configuration_check_param_logging_enabled"></a> [redshift\_cluster\_configuration\_check\_param\_logging\_enabled](#input\_redshift\_cluster\_configuration\_check\_param\_logging\_enabled) | (Optional) Boolean value indicating whether logging is enabled for the Redshift cluster | `string` | `"true"` | no |
| <a name="input_redshift_cluster_maintenancesettings_check_param_allow_version_upgrade"></a> [redshift\_cluster\_maintenancesettings\_check\_param\_allow\_version\_upgrade](#input\_redshift\_cluster\_maintenancesettings\_check\_param\_allow\_version\_upgrade) | (Optional) Boolean value indicating whether version upgrades are allowed for the Redshift cluster | `string` | `"true"` | no |
| <a name="input_restricted_incoming_traffic_param_blocked_port1"></a> [restricted\_incoming\_traffic\_param\_blocked\_port1](#input\_restricted\_incoming\_traffic\_param\_blocked\_port1) | (Optional) Port number to block for incoming traffic - 20 (FTP data transfer) | `string` | `"20"` | no |
| <a name="input_restricted_incoming_traffic_param_blocked_port2"></a> [restricted\_incoming\_traffic\_param\_blocked\_port2](#input\_restricted\_incoming\_traffic\_param\_blocked\_port2) | (Optional) Port number to block for incoming traffic - 21 (FTP control) | `string` | `"21"` | no |
| <a name="input_restricted_incoming_traffic_param_blocked_port3"></a> [restricted\_incoming\_traffic\_param\_blocked\_port3](#input\_restricted\_incoming\_traffic\_param\_blocked\_port3) | (Optional) Port number to block for incoming traffic - 3389 (RDP) | `string` | `"3389"` | no |
| <a name="input_restricted_incoming_traffic_param_blocked_port4"></a> [restricted\_incoming\_traffic\_param\_blocked\_port4](#input\_restricted\_incoming\_traffic\_param\_blocked\_port4) | (Optional) Port number to block for incoming traffic - 3306 (MySQL) | `string` | `"3306"` | no |
| <a name="input_restricted_incoming_traffic_param_blocked_port5"></a> [restricted\_incoming\_traffic\_param\_blocked\_port5](#input\_restricted\_incoming\_traffic\_param\_blocked\_port5) | (Optional) Port number to block for incoming traffic - 4333 | `string` | `"4333"` | no |
| <a name="input_vpc_sg_open_only_to_authorized_ports_param_authorized_tcp_ports"></a> [vpc\_sg\_open\_only\_to\_authorized\_ports\_param\_authorized\_tcp\_ports](#input\_vpc\_sg\_open\_only\_to\_authorized\_ports\_param\_authorized\_tcp\_ports) | (Optional) Comma-separated list of authorized TCP ports for inbound traffic to the VPC security group | `string` | `"443"` | no |

## Outputs

No outputs.
