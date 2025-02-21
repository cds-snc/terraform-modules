#########################################################################
### DocumentDB Input Variables
#########################################################################

variable "master_username" {
  description = "(Required) The username of the documentdb cluster."
  sensitive   = true
  type        = string
}

variable "master_password" {
  description = "(Required). The password of the documentdb cluster."
  sensitive   = true
  type        = string
}

variable "database_name" {
  description = "(Required). Name of the database."
  type        = string
}

variable "cluster_family" {
  type        = string
  default     = "docdb5.0"
  description = "(Required, default is `docdb5.0`). The family of the DocumentDB cluster parameter group. More information can be found at https://docs.aws.amazon.com/documentdb/latest/developerguide/cluster_parameter_groups.html"
}

variable "parameters" {
  type = list(object({
    apply_method = optional(string)
    name         = string
    value        = string
  }))
  default     = []
  description = "(Optional). List of parameters to apply to the DocumentDB database"
}

variable "backup_retention_period" {
  type        = string
  default     = "7"
  description = "(Optional, default is 7). The number of days that you should keep backups for."
}

variable "backup_window" {
  type        = string
  default     = "06:00-08:00"
  description = "(Optional, default is `06:00-08:00`). Daily time range that backups execute (UTC time). Default is at 1:00am - 3:00am EST."
}

variable "apply_immediately" {
  type        = bool
  description = "(Optional, default is `true`). Determines if any cluster modifications are applied immediately, or during the next maintenance window. Note that apply immediately can result in a brief downtime as the cluster reboots."
  default     = true
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "(Optional, default is `true`). Prevents the cluster from being deleted and indicates if deletion protection is enabled."
}

variable "storage_encrypted" {
  type        = bool
  description = "(Optional, default is `false`). Determines if the DB cluster is encrypted."
  default     = false
}

variable "kms_key_id" {
  type        = string
  description = "(Optional). The ARN for the KMS encryption key. If you are using a `kms_key_id` then the `storage_encrypted` variable needs to be set to `true`."
  default     = ""
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "(Optional). Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
}

variable "vpc_security_group_ids" {
  type        = set(string)
  default     = null
  description = "(Optional). A list of VPC security group IDs to associate with the DocumentDB cluster."
}

variable "engine" {
  type        = string
  default     = "docdb"
  description = "(Optional, default is `docdb`). The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`."
}

variable "instance_engine" {
  type        = string
  default     = "docdb"
  description = "(Optional, default is `docdb`). The name of the database engine to be used for the DocumentDB instance. Defaults to `docdb`. Valid values: `docdb`."
}

variable "engine_version" {
  type        = string
  default     = "5.0.0"
  description = "(Optional, default is `5.0.0`). The version number of the database engine to use. Note that updating this argument results in an outage."
}

variable "cluster_size" {
  type        = string
  default     = "1"
  description = "(Optional, default is 1). The number of DB instances to create in the cluster. The default value is 1."
}

variable "instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "(Required, default `db.t3.medium`) The instance class to use for the instance For more information on instance classes, refer to https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs."
}

variable "subnet_ids" {
  description = "(Required) List of VPC subnet IDs."
  type        = list(string)
}

variable "enable" {
  type        = bool
  default     = true
  description = "(Optional, default is `true`). Enables creation of resource."
}

variable "billing_code" {
  description = "(Required) The value of the billing code tag"
  type        = string
}

variable "default_tags" {
  description = "(Optional). Default tags for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}