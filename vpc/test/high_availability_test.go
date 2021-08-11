package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestHighAvailabilityVpc(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/high_availability",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// TODO: add assertions that VPC is setup as expected
}
