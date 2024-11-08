# Resolver DNS
This module enabled resolver DNS query logging so you can see the DNS queries being made by your VPC resources.

Optionally, it can also enable a resolver DNS firewall that only permits DNS queries for specific domains to resolve.  This helps prevent unexpected egress from your VPC resources.

## :warning: Note
Although this module helps prevent egress, it doesn't stop direct IP connections when a DNS query is not required.  To fully lock down your VPC egress, you should use Network ACLs and Security Groups that only allow egress to expected destinations.

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
| [aws_cloudwatch_log_group.route53_vpc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.route53_vpc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_route53_resolver_firewall_domain_list.allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_domain_list.blocked](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_rule.allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule.blocked](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule_group.firewall_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group) | resource |
| [aws_route53_resolver_firewall_rule_group_association.firewall_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group_association) | resource |
| [aws_route53_resolver_query_log_config.route53_vpc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config) | resource |
| [aws_route53_resolver_query_log_config_association.route53_vpc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config_association) | resource |
| [aws_iam_policy_document.route53_resolver_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | (Optional) List of domains to allow through the DNS firewall.  Required if `firewall_enabled` is true. | `list(string)` | <pre>[<br/>  "*."<br/>]</pre> | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_firewall_enabled"></a> [firewall\_enabled](#input\_firewall\_enabled) | (Optional) Should the resolver DNS firewall be enabled | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC to associate the query log and firewall with | `string` | n/a | yes |

## Outputs

No outputs.
