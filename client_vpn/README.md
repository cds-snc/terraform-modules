# Client VPN
Create a Client VPN endpoint in the specified VPC's subnets.  This can be used to provide secure access to private resources in the VPC.

Client authentication and authorization is managed by AWS IAM Identity Center.  Users must be added to the access group specified by the `access_group_id` variable in order to connect to the VPN.

The client VPN endpoint must be associated with the resource's subnet that you are providing access to.  For each association, there is a fixed $0.10/hour charge as well as a $0.05/hour charge for each active client connection.

## Credit
This module is based on the design of [fivexl/terraform-aws-client-vpn-endpoint](https://github.com/fivexl/terraform-aws-client-vpn-endpoint).

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.client_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ec2_client_vpn_authorization_rule.this_internal_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_authorization_rule.this_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_authorization_rule.this_subnets_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.this_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_iam_saml_provider.client_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_iam_saml_provider.client_vpn_self_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [tls_private_key.client_vpn](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.client_vpn](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_group_id"></a> [access\_group\_id](#input\_access\_group\_id) | (Required) IAM Identity Center access group ID that is authorized to access the private subnets. | `string` | n/a | yes |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | (Required) The ARN of the ACM server certificate to use for VPN client connection encryption. | `string` | n/a | yes |
| <a name="input_authentication_option"></a> [authentication\_option](#input\_authentication\_option) | (Optional, default 'federated-authentication') The authentication option to use for the VPN endpoint.  Valid values are 'federated-authentication' or 'certificate-authentication'. | `string` | `"federated-authentication"` | no |
| <a name="input_banner_text"></a> [banner\_text](#input\_banner\_text) | The text to display on the banner page when a user connects to the Client VPN endpoint. | `string` | `"This is a private network.  Only authorized users may connect and should take care not to cause service disruptions."` | no |
| <a name="input_billing_tag_key"></a> [billing\_tag\_key](#input\_billing\_tag\_key) | (Optional, default 'CostCentre') The name of the billing tag | `string` | `"CostCentre"` | no |
| <a name="input_billing_tag_value"></a> [billing\_tag\_value](#input\_billing\_tag\_value) | (Required) The value of the billing tag | `string` | n/a | yes |
| <a name="input_client_vpn_saml_metadata_document"></a> [client\_vpn\_saml\_metadata\_document](#input\_client\_vpn\_saml\_metadata\_document) | (Optional, default empty) The base64 encoded SAML metadata document for the Client VPN endpoint | `string` | `""` | no |
| <a name="input_client_vpn_self_service_saml_metadata_document"></a> [client\_vpn\_self\_service\_saml\_metadata\_document](#input\_client\_vpn\_self\_service\_saml\_metadata\_document) | (Optional, default empty) The base64 encoded SAML metadata document for the Client VPN's self-service endpoint. The self\_service\_portal variable must be set to 'enabled' for this to take effect. | `string` | `""` | no |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | (Optional, default 'cds-snc.ca') The common name to use for the VPN client certificate. | `string` | `"cds-snc.ca"` | no |
| <a name="input_endpoint_cidr_block"></a> [endpoint\_cidr\_block](#input\_endpoint\_cidr\_block) | (Optional, default '172.16.0.0/22') The CIDR block to use for the VPN endpoint. | `string` | `"172.16.0.0/22"` | no |
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name) | (Required) The name of the VPN endpoint to create. It must only contain alphanumeric characters, hyphens and underscores. | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | (Optional, default 'Canadian Digital Service') The organization to use for the VPN client certificate. | `string` | `"Canadian Digital Service"` | no |
| <a name="input_public_dns_servers"></a> [public\_dns\_servers](#input\_public\_dns\_servers) | (Optional, default ['8.8.8.8']) Public DNS servers to add to the VPN. | `list(string)` | <pre>[<br/>  "8.8.8.8"<br/>]</pre> | no |
| <a name="input_self_service_portal"></a> [self\_service\_portal](#input\_self\_service\_portal) | (Optional, default 'disabled') Should a self-service portal be created for users to download the VPN client software? | `string` | `"disabled"` | no |
| <a name="input_session_timeout_hours"></a> [session\_timeout\_hours](#input\_session\_timeout\_hours) | (Optional, default 8) The maximum number of hours after which to automatically disconnect a session.  Allowed values are 8, 10, 12, 24 | `number` | `8` | no |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | (Optional, default true) Whether to enable split tunneling for the VPN endpoint. | `bool` | `true` | no |
| <a name="input_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#input\_subnet\_cidr\_blocks) | (Required) CIDR blocks of the subnets to associate with the VPN endpoint. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Optional, default []) IDs of the subnets to associate with the VPN endpoint.  If left blank, no subnets will be associated with the VPN client endpoint, removing the $0.10/hour/association cost. | `list(string)` | `[]` | no |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol) | (Optional, default 'udp') Transport protocol to use for the VPN endpoint.  Valid values are 'tcp' or 'udp'. | `string` | `"udp"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | (Required) The CIDR block of the VPC to associate with the VPN endpoint. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) ID of the VPC to associate with the VPN endpoint. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_vpn_certificate_pem"></a> [client\_vpn\_certificate\_pem](#output\_client\_vpn\_certificate\_pem) | Client VPN's certificate PEM |
| <a name="output_client_vpn_cloudwatch_log_group_name"></a> [client\_vpn\_cloudwatch\_log\_group\_name](#output\_client\_vpn\_cloudwatch\_log\_group\_name) | Client VPN's CloudWatch log group name |
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | Client VPN's endpoint ID |
| <a name="output_client_vpn_private_key_pem"></a> [client\_vpn\_private\_key\_pem](#output\_client\_vpn\_private\_key\_pem) | Client VPN's private key PEM |
| <a name="output_client_vpn_security_group_id"></a> [client\_vpn\_security\_group\_id](#output\_client\_vpn\_security\_group\_id) | Client VPN's security group ID |
