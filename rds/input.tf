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

variable "database_name" {
  type        = string
  description = "(Required) The name of the database to be created inside the cluster."

  validation {
    condition     = can(regex("^[[:alpha:]][[:alnum:]]+$", var.database_name))
    error_message = "Database name must begin with a letter and contain only alphanumeric characters."
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

variable "prevent_cluster_deletion" {
  type        = bool
  description = "(Optional, default 'true') This flag prevents deletion of the RDS cluster. <br/> **Please Note:** We cannot prevent deletion of RDS instances in the module, we recommend you add `lifecycle { prevent_deletion = true }` to the module to prevent instance deletion"
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "(Optional, default 'false') This flag determines if a final database snapshot it taken before the cluster is deleted."
  default     = false
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

