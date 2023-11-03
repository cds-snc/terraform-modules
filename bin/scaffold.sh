#!/bin/bash

echo 🚧 Terraform Module Scaffold 🚧

# shellcheck disable=SC2162
read -p "Scaffold Name: " module

mkdir -p "$module"

echo 🚧 Creating module

echo 📝 Creating "$module/Makefile"
cat << EOF > "$module/Makefile"
.PHONY: fmt docs test

fmt:
	@terraform fmt -recursive

docs:
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md

test:
	terraform init &&\
	terraform test --var-file=./tests/globals.tfvars	
EOF

echo 📝 Creating "$module/input.tf"
cat << EOF > "$module/input.tf"

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

echo 📝 Creating "$module/locals.tf"
cat << EOF > "$module/locals.tf"

locals {
  common_tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = "true"
  }
}

EOF

echo 📝 Creating "$module/main.tf"
cat << EOF > "$module/main.tf"
/* # $module
*
*/
EOF

echo 👉 Touching "$module/output.tf"
touch "$module/output.tf"

echo ⚒️ Creating "$module/examples"
mkdir -p "$module/examples/simple"

echo 📝 Creating "$module/examples/simple/simple.tf"
cat << EOF > "$module/examples/simple/simple.tf"

module "simple" {
  source = "../../"

  billing_tag_value = "Terratest"
}

EOF

echo ⚒️ Creating "$module/tests"
mkdir -p "$module/tests"

echo 📝 Creating "$module/tests/globals.tfvars"
cat << EOF > "$module/tests/globals.tfvars"
billing_tag_value = "tests"
EOF

echo 📝 Creating "$module/tests/unit.main.tftest.hcl"
cat << EOF > "$module/tests/unit.main.tftest.hcl"
provider "aws" {
  region = "ca-central-1"
}

variables {
}

run "test_case" {
  command = plan
}
EOF

echo "📝 Appending to .modules file, (this adds it to the Makefile)"
echo -n " $module" >> .modules

[ -f "$module/Makefile" ]
[ -f "$module/input.tf" ]
[ -f "$module/locals.tf" ]
[ -f "$module/main.tf" ]
[ -f "$module/output.tf" ]
echo ✅ Done