#!/bin/bash

echo 🚧 Terraform Module Scaffold 🚧

# shellcheck disable=SC2162
read -p "Scaffold Name: " module

mkdir -p "$module"

echo 🚧 Creating module

echo 📝 Creating "$module/Makefile"
cat << EOF > "$module/Makefile"
.PHONY: fmt docs

fmt:
	@terraform fmt -recursive

docs:
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md
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

echo ⚒️ Creating "$module/test"
mkdir -p "$module/test"

echo 📝 Creating "$module/test/simple_test.go"
cat << EOF > "$module/test/simple_test.go"
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestSimple(t *testing.T) {
	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)
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