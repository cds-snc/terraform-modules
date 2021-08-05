variable "instances" {
  description = "The number of RDS Cluster instances to create, defaults to HA mode."
  type        = number
  default     = 3
}

variable "instance_class" {
  type        = string
  description = "The type of EC2 instance to run this on."
  default     = "db.t3.medium"
}

variable "name" {
  description = "(required) The name of the db also used for other identifiers"
  type        = string
}

variable "database_name" {
  type        = string
  description = "(required) The name of the database to be created inside the cluster."
}

variable "engine_version" {
  type        = string
  description = "(required) The Postgresql database version to use. Engine version is contingent on instance_class see (this list of supported combinations)[https://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora]"
}
variable "allow_major_version_upgrade" {
  type        = bool
  description = "This flag allows RDS to perform a major engine upgrade. <br/> **Please Note:** This could break things so make sure you know that your code is compatible with the new features in this version."
  default     = false
}

variable "prevent_cluster_deletion" {
  type        = bool
  description = "This flag prevents deletion of the RDS cluster. <br/> **Please Note:** We cannot prevent deletion of RDS instances in the module, we recommend you add `lifecycle { prevent_deletion = true }` to the module to prevent instance deletion"
  default     = true
}

###
# Common tags
###
variable "billing_tag_key" {
  description = "The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}

###
# Database retention options
###

variable "preferred_backup_window" {
  description = "(required) The time you want your DB to be backedup. Takes the format `\"07:00-09:00\"`"
  type        = string
}

variable "backup_retention_period" {
  description = "(required) The amount of days to keep backups for."
  type        = number
}


###
# Network info
###

variable "vpc_id" {
  description = "(required) The vpc to run the cluster and related infrastructure in"
  type        = string
}

variable "subnet_ids" {
  description = "(required) The name of the subnet the DB has to stay in"
  type        = set(string)
}

###
# Database Admin User
###

variable "username" {
  description = "(required) The username for the admin user for the db"
  type        = string
}

variable "password" {
  type        = string
  description = "(required) The password for the admin user for the db"
  sensitive   = true
}

###
# Proxy Configuration
###

variable "proxy_log_retention_in_days" {
  type        = number
  description = "The number of days to retain the proxy logs in cloudwatch"
  default     = 14
}

variable "proxy_debug_logging" {
  type        = bool
  description = "Allows the proxy to log debug information. <br/> **Please Note:** This will include all sql commands and potential sensitive information"
  default     = false
}

###
# Database Configuration
###

