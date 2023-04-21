/* 
* # CDS Conformance Pack
* 
* This module creates a conformance pack for CDS based on the CCCS conformance pack found here: https://github.com/awslabs/aws-config-rules/blob/master/aws-config-conformance-packs/Operational-Best-Practices-for-CCCS-Medium.yaml
* 
* It uses the same default inputs for terraform as specified in the CCCS conformance pack YAML, but can easily be overridden.
* 
* For example to meet the config rule `internet-gateway-authorized-vpc-only` you can set the authorized vpcs as follows:
* 
* ```hcl
* module "conformance_pack" {
*   source                                                        = "github.com/cds-snc/terraform-modules?ref=v5.1.6/cds_conformance_pack"
*   internet_gateway_authorized_vpc_only_param_authorized_vpc_ids = "vpc-00534274da4ade29d"
*   billing_tag_value = var.billing_code
* }
* ```
*/


resource "aws_config_conformance_pack" "cds_conformance_pack" {
  name = "CDSConformancePack"

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

  template_body = file("${path.module}/Operational-Best-Practices-for-CCCS-Medium.yaml")
}
