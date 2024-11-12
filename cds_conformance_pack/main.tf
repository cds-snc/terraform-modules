/* 
* # CDS Conformance Pack
* 
* This module creates a conformance pack for CDS based on the CCCS conformance pack found here: https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CCCS-Medium.yaml
* 
* It uses the same default inputs for terraform as specified in the CCCS conformance pack YAML, but can easily be overridden. Because a cloudformation template can only be 50kb in size when it is created over the wire, we need to create a bucket and upload the conformance pack to it. This module creates a bucket and uploads the conformance pack to it. The name of the bucket is based on the pattern `cds-conformance-pack-<random-uuid>`.
* 
* For example to meet the config rule `internet-gateway-authorized-vpc-only` you can set the authorized vpcs as follows:
* 
* ```hcl
* module "conformance_pack" {
*   source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
*   internet_gateway_authorized_vpc_only_param_authorized_vpc_ids = "vpc-00534274da4ade29d"
*   billing_tag_value                                             = var.billing_code
* }
* ```
*
* To exclude specific rules from the conformance pack, you can use the `excluded_rules` variable. For example, to exclude the `internet-gateway-authorized-vpc-only` rule, you can set the variable as follows:
*
* ```hcl
* module "conformance_pack" {
*   source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
*   excluded_rules                                                = ["InternetGatewayAuthorizedVpcOnly"]
*   billing_tag_value                                             = var.billing_code
* }
* ```
* 
* Note: The rules need to be in the CamelCase format as found in the YAML.
*
* If you would like to append or override the default conformance pack, you can use the `custom_conformance_pack_path` variable. For example, to append a rule to the conformance pack, you can set the variable as follows:
*
* ```hcl
* module "conformance_pack" {
*   source                                                        = "github.com/cds-snc/terraform-modules//cds_conformance_pack?ref=v5.1.8"
*   custom_conformance_pack_path                                  = "./custom_conformance_pack.yaml"
*   billing_tag_value                                             = var.billing_code
* }
* ```
* The custom conformance pack should be in the same format as the CCCS conformance pack YAML, in that you can use a `Parameters`, `Resources`, and `Conditions` section. 
*
*/

resource "random_uuid" "bucket_suffix" {}

module "s3" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "cds-conformance-pack-${random_uuid.bucket_suffix.result}"
  billing_tag_value = var.billing_tag_value
}

resource "aws_s3_object" "conformace_pack_yaml" {
  bucket  = module.s3.s3_bucket_id
  key     = "CDSConformancePack.yaml"
  content = yamlencode(local.modified_conformance_pack)
}


resource "aws_config_conformance_pack" "cds_conformance_pack" {
  name = var.conformance_pack_name

  input_parameter {
    parameter_name  = "AccessKeysRotatedParamMaxAccessKeyAge"
    parameter_value = var.access_keys_rotated_param_max_access_key_age
  }

  input_parameter {
    parameter_name  = "CloudwatchAlarmActionCheckParamAlarmActionRequired"
    parameter_value = var.cloudwatch_alarm_action_check_param_alarm_action_required
  }

  input_parameter {
    parameter_name  = "CloudwatchAlarmActionCheckParamInsufficientDataActionRequired"
    parameter_value = var.cloudwatch_alarm_action_check_param_insufficient_data_action_required
  }

  input_parameter {
    parameter_name  = "CloudwatchAlarmActionCheckParamOkActionRequired"
    parameter_value = var.cloudwatch_alarm_action_check_param_ok_action_required
  }

  input_parameter {
    parameter_name  = "ElbPredefinedSecurityPolicySslCheckParamPredefinedPolicyName"
    parameter_value = var.elb_predefined_security_policy_ssl_check_param_predefined_policy_name
  }

  input_parameter {
    parameter_name  = "IamCustomerPolicyBlockedKmsActionsParamBlockedActionsPatterns"
    parameter_value = var.iam_customer_policy_blocked_kms_actions_param_blocked_actions_patterns
  }

  input_parameter {
    parameter_name  = "IamInlinePolicyBlockedKmsActionsParamBlockedActionsPatterns"
    parameter_value = var.iam_inline_policy_blocked_kms_actions_param_blocked_actions_patterns
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamMaxPasswordAge"
    parameter_value = var.iam_password_policy_param_max_password_age
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamMinimumPasswordLength"
    parameter_value = var.iam_password_policy_param_minimum_password_length
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamPasswordReusePrevention"
    parameter_value = var.iam_password_policy_param_password_reuse_prevention
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireLowercaseCharacters"
    parameter_value = var.iam_password_policy_param_require_lowercase_characters
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireNumbers"
    parameter_value = var.iam_password_policy_param_require_numbers
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireSymbols"
    parameter_value = var.iam_password_policy_param_require_symbols
  }

  input_parameter {
    parameter_name  = "IamPasswordPolicyParamRequireUppercaseCharacters"
    parameter_value = var.iam_password_policy_param_require_uppercase_characters
  }

  input_parameter {
    parameter_name  = "IamUserUnusedCredentialsCheckParamMaxCredentialUsageAge"
    parameter_value = var.iam_user_unused_credentials_check_param_max_credential_usage_age
  }

  input_parameter {
    parameter_name  = "InternetGatewayAuthorizedVpcOnlyParamAuthorizedVpcIds"
    parameter_value = var.internet_gateway_authorized_vpc_only_param_authorized_vpc_ids
  }

  input_parameter {
    parameter_name  = "RedshiftClusterConfigurationCheckParamClusterDbEncrypted"
    parameter_value = var.redshift_cluster_configuration_check_param_cluster_db_encrypted
  }

  input_parameter {
    parameter_name  = "RedshiftClusterConfigurationCheckParamLoggingEnabled"
    parameter_value = var.redshift_cluster_configuration_check_param_logging_enabled
  }

  input_parameter {
    parameter_name  = "RedshiftClusterMaintenancesettingsCheckParamAllowVersionUpgrade"
    parameter_value = var.redshift_cluster_maintenancesettings_check_param_allow_version_upgrade
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort1"
    parameter_value = var.restricted_incoming_traffic_param_blocked_port1
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort2"
    parameter_value = var.restricted_incoming_traffic_param_blocked_port2
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort3"
    parameter_value = var.restricted_incoming_traffic_param_blocked_port3
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort4"
    parameter_value = var.restricted_incoming_traffic_param_blocked_port4
  }

  input_parameter {
    parameter_name  = "RestrictedIncomingTrafficParamBlockedPort5"
    parameter_value = var.restricted_incoming_traffic_param_blocked_port5
  }

  input_parameter {
    parameter_name  = "VpcSgOpenOnlyToAuthorizedPortsParamAuthorizedTcpPorts"
    parameter_value = var.vpc_sg_open_only_to_authorized_ports_param_authorized_tcp_ports
  }

  template_s3_uri = "s3://${module.s3.s3_bucket_id}/CDSConformancePack.yaml"

  lifecycle {
    replace_triggered_by = [
      aws_s3_object.conformace_pack_yaml.content
    ]
  }

  depends_on = [
    aws_s3_object.conformace_pack_yaml
  ]
}
