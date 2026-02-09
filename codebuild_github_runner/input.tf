variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

variable "build_timeout" {
  description = "(Optional, default '30') Build timeout for the CodeBuild project."
  type        = number
  default     = 30
}

variable "environment_compute_type" {
  description = "(Optional, default 'BUILD_GENERAL1_SMALL') Compute type for the CodeBuild environment."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_image" {
  description = "(Optional, default 'aws/codebuild/amazonlinux2-x86_64-standard:5.0') Image for the CodeBuild environment."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "environment_image_pull_credentials_type" {
  description = "(Optional, default 'CODEBUILD') Image pull credentials type for the CodeBuild environment."
  type        = string
  default     = "CODEBUILD"
}

variable "environment_type" {
  description = "(Optional, default 'LINUX_CONTAINER') Environment type for the CodeBuild project."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "environment_variables" {
  description = "(Optional, default []) Environment variables for the CodeBuild project."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "github_codeconnection_name" {
  description = "(Optional) Name of the GitHub Code Star connection to GitHub."
  type        = string
  default     = ""
}

variable "github_personal_access_token" {
  description = "(Optional) GitHub personal access token to allow the CodeBuild runner access to the target GitHub repository."
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_repository_url" {
  description = "(Required) GitHub repository URL for the CodeBuild source."
  type        = string

  validation {
    condition     = can(regex("https://github.com/.+/.+\\.git$", var.github_repository_url))
    error_message = "GitHub repository must be a full URL including protocal and ending in '.git'."
  }
}

variable "project_name" {
  description = "(Required) Name of the CodeBuild project."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name))
    error_message = "Project name must only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "queued_timeout" {
  description = "(Optional, default '5') Queued timeout for the CodeBuild project."
  type        = number
  default     = 5
}