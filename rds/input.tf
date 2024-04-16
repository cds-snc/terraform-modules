variable "instances" {
  description = "(Optional, default '3') The number of RDS Cluster instances to create, defaults to HA mode."
  type        = number
  default     = 3
}

variable "instance_class" {
  type        = string
  description = "(Optional, default 'db.t3.medium') The type of EC2 instance to run this on."
  default     = "db.t3.medium"
}

variable "name" {
  description = "(Required) The name of the db also used for other identifiers"
  type        = string
}

variable "cloudwatch_log_exports_retention_in_days" {
  description = "(Optional, default 7) The number of days to store exported database logs in the CloudWatch log group."
  type        = number
  default     = 7
}

variable "database_name" {
  type        = string
  description = "(Required) The name of the database to be created inside the cluster."

  validation {
    condition     = can(regex("^[A-Za-z][0-9A-Za-z_-]*$", var.database_name))
    error_message = "Database name must begin with a letter and contain only alphanumeric, hyphen and underscore characters."
  }
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "(Optional, no default) Name of DB cluster parameter group to associate with this DB cluster."
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "(Optional, default empty list) The database log types to export to CloudWatch. Valid values are `audit`, `error`, `general`, `slowquery`, `postgresql`."
  default     = []

  validation {
    condition = alltrue([
      for e in var.enabled_cloudwatch_logs_exports : contains(["audit", "error", "general", "slowquery", "postgresql"], e)
    ])
    error_message = "CloudWatch log exports valid values are `audit`, `error`, `general`, `slowquery`, and `postgresql`."
  }
}

variable "engine" {
  type        = string
  description = "(Optional, defaults 'aurora-postgresql') The database engine to use. Valid values are 'aurora-postgresql' and 'aurora-mysql'"
  default     = "aurora-postgresql"

  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "Database engine must be 'aurora-postgresql' or 'aurora-mysql'."
  }
}

variable "engine_version" {
  type        = string
  description = "(Required) The database version to use. Engine version is contingent on instance_class see [this list of supported combinations](https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora)"
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "(Optional, default 'false') This flag allows RDS to perform a major engine upgrade. <br/> **Please Note:** This could break things so make sure you know that your code is compatible with the new features in this version."
  default     = false
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "(Optional, default 'false') Enable IAM database authentication for the RDS cluster."
  default     = false
}

variable "performance_insights_enabled" {
  type        = bool
  description = "(Optional, default 'true') This flag enables performance insights for the RDS cluster instances."
  default     = true
}

variable "prevent_cluster_deletion" {
  type        = bool
  description = "(Optional, default 'true') This flag prevents deletion of the RDS cluster. <br/> **Please Note:** We cannot prevent deletion of RDS instances in the module, we recommend you add `lifecycle { prevent_deletion = true }` to the module to prevent instance deletion"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "(Optional, default '[]') A list of additional security group IDs to associate with the RDS cluster."
  default     = []
}

variable "skip_final_snapshot" {
  type        = bool
  description = "(Optional, default 'false') This flag determines if a final database snapshot it taken before the cluster is deleted."
  default     = false
}

variable "snapshot_identifier" {
  type        = string
  description = "(Optional, no default) The name or ARN of the DB cluster snapshot to create the cluster from."
  default     = null
}

###
# Common tags
###
variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

###
# Database retention options
###

variable "preferred_backup_window" {
  description = "(Required) The time you want your DB to be backedup. Takes the format `\"07:00-09:00\"`"
  type        = string
}

variable "backup_retention_period" {
  description = "(Required) The amount of days to keep backups for."
  type        = number
}

variable "preferred_maintenance_window" {
  description = "(Optional) The UTC time you want your DB to be maintained. Takes the format `\"wed:06:00-wed:07:00\"`"
  type        = string
  default     = "sun:06:00-sun:07:00"
}


###
# Network info
###

variable "vpc_id" {
  description = "(Required) The vpc to run the cluster and related infrastructure in"
  type        = string
}

variable "subnet_ids" {
  description = "(Required) The name of the subnet the DB has to stay in"
  type        = set(string)
}

###
# Database Admin User
###

variable "username" {
  description = "(Required) The username for the admin user for the db"
  type        = string

  validation {
    condition     = var.username != "admin"
    error_message = "Database username cannot be 'admin'."
  }
}

variable "password" {
  type        = string
  description = "(Required) The password for the admin user for the db"
  sensitive   = true
}

variable "upgrade_immediately" {
  description = "(Optional, default false) Apply database engine upgrades immediately."
  type        = bool
  default     = false
}

###
# Proxy Configuration
###

variable "proxy_log_retention_in_days" {
  type        = number
  description = "(Optional, default '14') The number of days to retain the proxy logs in cloudwatch"
  default     = 14
}

variable "proxy_debug_logging" {
  type        = bool
  description = "(Optional, default 'false') Allows the proxy to log debug information. <br/> **Please Note:** This will include all sql commands and potential sensitive information"
  default     = false
}

###
# Database Configuration
###

variable "serverless_min_capacity" {
  type        = number
  description = "(Optional) The minimum capacity of the Aurora serverless cluster (0.5 to 128 in increments of 0.5)"
  default     = 0
  validation {
    condition     = var.serverless_min_capacity >= 0 && var.serverless_min_capacity <= 128 && var.serverless_min_capacity % 0.5 == 0
    error_message = "Serverless_min_capacity must be between 0.5 and 128 in increments of 0.5."
  }
}

variable "serverless_max_capacity" {
  type        = number
  description = "(Optional) The maximum capacity of the Aurora serverless cluster (0.5 to 128 in increments of 0.5)"
  default     = 0
  validation {
    condition     = var.serverless_max_capacity >= 0 && var.serverless_max_capacity <= 128 && var.serverless_max_capacity % 0.5 == 0
    error_message = "Serverless_max_capacity must be between 0.5 and 128 in increments of 0.5."
  }
}

###
# Monitoring options
###

variable "security_group_notifications_topic_arn" {
  type        = string
  description = "(Optional) The SNS topic ARN to send notifications about security group changes to."
  default     = ""
}

variable "backtrack_window" {
  type        = number
  description = "(Optional, defaults to 72 hours) The number of days to retain a backtrack. Set to 0 to disable backtracking.  This is only valid for the `aurora-mysql` engine type."
  default     = 259200
}