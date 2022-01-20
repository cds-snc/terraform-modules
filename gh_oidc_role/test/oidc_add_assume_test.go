package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestOIDCWithAdditionalAssumeRoleCreation(t *testing.T) {

	region := "ca-central-1"

	// There is a delay from when terraform deletes the oidc provider and when
	// it disappears from AWS.  These retries will allow the creation of the oidc
	// provider to eventually succeed.
	maxRetries := 3
	timeBetweenRetries := 10 * time.Second
	retryableTerraformErrors := map[string]string{
		".*error creating IAM OIDC Provider*": "EntityAlreadyExists*",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/oidc_add_assume",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		MaxRetries:               maxRetries,
		TimeBetweenRetries:       timeBetweenRetries,
		RetryableTerraformErrors: retryableTerraformErrors,
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)
}
