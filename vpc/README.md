# Virtual Private Cloud (VPC)

This module creates a pre-configured VPC with a pair of subnets split over one or many availability zones (AZ). Each of the AZs created has a public and private subnet. The public subnet has a public IP address attached and has a route to the internet. The private subnet has a route to the internet through a nat gateway.

## Architecture

This module allows you to deploy two types of architecture high availability and single zone mode.

### High Availability Mode

**Please Note:** This might not work outside of ca-central-1

High Availability mode deploys in each AZ in a region. This is what you should chose if you want to target Protected B, Medium Integrity, Medium Availability (PBMM).
![Diagram of the High Availiablity Zone architecture](./docs/high\_availability\_zone.png)

### Single Zone mode

**Please Note:** This should not be used in a PBMM Production environment.

Single Zone mode deployes in the first AZ in a region that is found by the availability lookup. This will work for if you want to save money in dev.

![Diagram of the Single Zone architecture](./docs/single\_zone.png)

### Breaking change with v9.0.0
If you upgrade to v9.0.0 or above from a lower version, the `high_availability` flag is deprecated and no longer available. You will need to do the following in order to upgrade to a higher version:
1. Remove the `high_availability` flag
2. Instead add the following to your code:
 ```
   availability_zones = 3
   cidrsubnet_newbits = 8
```
3. Run terraform/terragrunt plan. You should have no changes in your infrastucture.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_network_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.vpc_metrics_flow_logs_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vpc_metrics_flow_logs_write_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.block_rdp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.block_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_egress_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_in_ingress_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_in_ingress_ephemeral](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_in_response_egress_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_in_response_egress_ephemeral](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_out_egress_ephemeral](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_out_response_ingress_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.https_request_out_response_ingress_ephemeral](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.vpc_flow_logs_service_principal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_metrics_flow_logs_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_https_request_in"></a> [allow\_https\_request\_in](#input\_allow\_https\_request\_in) | (Optional, default 'false') Allow HTTPS connections on port 443 in from the internet | `bool` | `false` | no |
| <a name="input_allow_https_request_in_response"></a> [allow\_https\_request\_in\_response](#input\_allow\_https\_request\_in\_response) | (Optional, default 'false') Allow a response back to the internet in reply to a request | `bool` | `false` | no |
| <a name="input_allow_https_request_out"></a> [allow\_https\_request\_out](#input\_allow\_https\_request\_out) | (Optional, default 'false') Allow HTTPS connections on port 443 out to the internet | `bool` | `false` | no |
| <a name="input_allow_https_request_out_response"></a> [allow\_https\_request\_out\_response](#input\_allow\_https\_request\_out\_response) | (Optional, default 'false') Allow a response back from the internet in reply to a request | `bool` | `false` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional, default '1') The number of availability zones to use | `number` | `1` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_block_rdp"></a> [block\_rdp](#input\_block\_rdp) | (Optional, default 'true') Whether or not to block Port 3389 | `bool` | `true` | no |
| <a name="input_block_ssh"></a> [block\_ssh](#input\_block\_ssh) | (Optional, default 'true') Whether or not to block Port 22 | `bool` | `true` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | (Optional, default '10.0.0.0/16') The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cidrsubnet_newbits"></a> [cidrsubnet\_newbits](#input\_cidrsubnet\_newbits) | (Optional, default '10') The number of additional bits with which to extend the cidr subnet prefix | `number` | `10` | no |
| <a name="input_enable_eip"></a> [enable\_eip](#input\_enable\_eip) | (Optional, default 'true') Enables Elastic IPs, disabling is mainly used for testing purposes | `bool` | `true` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | (Optional, default 'false') Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the vpc | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | (Optional, default []) A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | (Optional, default []) A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr_block"></a> [cidr\_block](#output\_cidr\_block) | n/a |
| <a name="output_main_nacl_id"></a> [main\_nacl\_id](#output\_main\_nacl\_id) | n/a |
| <a name="output_main_route_table_id"></a> [main\_route\_table\_id](#output\_main\_route\_table\_id) | n/a |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | n/a |
| <a name="output_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#output\_private\_subnet\_cidr\_blocks) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | n/a |
| <a name="output_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#output\_public\_subnet\_cidr\_blocks) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
