#!/bin/bash

folder=$1

echo 🚧‍ Start Scaffolding 🚧

echo making folder
mkdir $folder

echo main.tf
cat << EOF > $folder/main.tf
/* # $folder
*
*/
EOF

echo inputs.tf
cat << EOF > $folder/inputs.tf

###
# Common tags
###
variable "billing_tag_key" {
  description = "(Optional) The name of the billing tag"
  type        = string
  default     = "CostCentre"
}

variable "billing_tag_value" {
  description = "(required) The value of the billing tag"
  type        = string
}
EOF

echo locals.tf
cat << EOF > $folder/locals.tf

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

EOF
echo outputs
touch $folder/outputs.tf

echo 🚧 End Scaffolding 🚧