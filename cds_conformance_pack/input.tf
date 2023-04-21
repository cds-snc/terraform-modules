variable "access_keys_rotated_param_max_access_key_age" {
  description = "(Optional) The maximum age in days before an access key must be rotated."
  type        = string
  default     = "90"
}

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "cloudwatch_alarm_action_check_param_alarm_action_required" {
  description = "(Optional) Indicates whether an action is required when the alarm changes to the ALARM state."
  type        = string
  default     = "true"
}

variable "cloudwatch_alarm_action_check_param_insufficient_data_action_required" {
  description = "(Optional) Indicates whether an action is required when the alarm changes to the INSUFFICIENT_DATA state."
  type        = string
  default     = "true"
}

variable "cloudwatch_alarm_action_check_param_ok_action_required" {
  description = "(Optional) Indicates whether an action is required when the alarm changes to the OK state."
  type        = string
  default     = "false"
}

variable "elb_predefined_security_policy_ssl_check_param_predefined_policy_name" {
  description = "(Optional) The name of the predefined security policy for the ELB SSL negotiation configuration."
  type        = string
  default     = "TLS-1-2-2017-01"
}

variable "iam_customer_policy_blocked_kms_actions_param_blocked_actions_patterns" {
  description = "(Optional) The patterns of KMS actions to be blocked in the customer-managed IAM policy."
  type        = string
  default     = "kms:*, kms:Decrypt, kms:ReEncrypt*"
}

variable "iam_inline_policy_blocked_kms_actions_param_blocked_actions_patterns" {
  description = "(Optional) The patterns of KMS actions to be blocked in the inline IAM policy."
  type        = string
  default     = "kms:*, kms:Decrypt, kms:ReEncrypt*"
}

variable "iam_password_policy_param_max_password_age" {
  description = "(Optional) The maximum password age in days for IAM users."
  type        = string
  default     = "90"
}

variable "iam_password_policy_param_minimum_password_length" {
  description = "(Optional) The minimum length for IAM user passwords."
  type        = string
  default     = "14"
}

variable "iam_password_policy_param_password_reuse_prevention" {
  description = "(Optional) The number of previous passwords that IAM users are prevented from reusing."
  type        = string
  default     = "24"
}

variable "iam_password_policy_param_require_lowercase_characters" {
  description = "(Optional) Indicates whether IAM user passwords must contain at least one lowercase letter."
  type        = string
  default     = "true"
}

variable "iam_password_policy_param_require_numbers" {
  description = "(Optional) Indicates whether IAM user passwords must contain at least one number."
  type        = string
  default     = "true"
}

variable "iam_password_policy_param_require_symbols" {
  description = "(Optional) Indicates whether IAM user passwords must contain at least one symbol."
  type        = string
  default     = "true"
}

variable "iam_password_policy_param_require_uppercase_characters" {
  description = "(Optional) Indicates whether IAM user passwords must contain at least one uppercase letter."
  type        = string
  default     = "true"
}

variable "iam_user_unused_credentials_check_param_max_credential_usage_age" {
  description = "(Optional) The maximum age in days for IAM user credentials that have not been used."
  type        = string
  default     = "90"
}

variable "internet_gateway_authorized_vpc_only_param_authorized_vpc_ids" {
  description = "(Optional) Comma-separated list of authorized VPC IDs that are allowed to use the Internet Gateway"
  type        = string
  default     = "here add Comma-separated list of the authorized VPC IDs"
}

variable "redshift_cluster_configuration_check_param_cluster_db_encrypted" {
  description = "(Optional) Boolean value indicating whether the Redshift cluster's database is encrypted"
  type        = string
  default     = "true"
}

variable "redshift_cluster_configuration_check_param_logging_enabled" {
  description = "(Optional) Boolean value indicating whether logging is enabled for the Redshift cluster"
  type        = string
  default     = "true"
}

variable "redshift_cluster_maintenancesettings_check_param_allow_version_upgrade" {
  description = "(Optional) Boolean value indicating whether version upgrades are allowed for the Redshift cluster"
  type        = string
  default     = "true"
}

variable "restricted_incoming_traffic_param_blocked_port1" {
  description = "(Optional) Port number to block for incoming traffic - 20 (FTP data transfer)"
  type        = string
  default     = "20"
}

variable "restricted_incoming_traffic_param_blocked_port2" {
  description = "(Optional) Port number to block for incoming traffic - 21 (FTP control)"
  type        = string
  default     = "21"
}

variable "restricted_incoming_traffic_param_blocked_port3" {
  description = "(Optional) Port number to block for incoming traffic - 3389 (RDP)"
  type        = string
  default     = "3389"
}

variable "restricted_incoming_traffic_param_blocked_port4" {
  description = "(Optional) Port number to block for incoming traffic - 3306 (MySQL)"
  type        = string
  default     = "3306"
}

variable "restricted_incoming_traffic_param_blocked_port5" {
  description = "(Optional) Port number to block for incoming traffic - 4333"
  type        = string
  default     = "4333"
}

variable "vpc_sg_open_only_to_authorized_ports_param_authorized_tcp_ports" {
  description = "(Optional) Comma-separated list of authorized TCP ports for inbound traffic to the VPC security group"
  type        = string
  default     = "443"
}
