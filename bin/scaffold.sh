#!/bin/bash

module=$1

mkdir -p $module

echo 🚧 Creating module

echo 📝 Create $module/input.tf
cat << EOF > $module/input.tf

variable "billing_tag_key" {
  description = "(Optional, default 'CostCentre') The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(Required) The value of the billing tag"
  type        = string
}

EOF

echo 📝 Create $module/locals.tf
cat << EOF > $module/locals.tf

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

EOF

echo 📝 Create $module/main.tf
cat << EOF > $module/main.tf
/* # $module
*
*/
EOF

echo 👉 Touching output.tf
touch output.tf

[ -f $module/input.tf ] 
[ -f $module/locals.tf ] 
[ -f $module/main.tf ] 
[ -f $module/output.tf ] 
echo ✅ Done
