package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTwoInstanceCluster(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	// The RDS proxy is flaky and will sometimes not attach properly due to the
	// cluster being in an unexpected state.  These retries give things time to settle down.
	maxRetries := 3
	timeBetweenRetries := 10 * time.Second
	retryableTerraformErrors := map[string]string{
		".*error registering RDS DB Proxy.*": "Failed to register RDS DB proxy",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/two_instance_cluster",
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
