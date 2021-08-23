package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTwoInstanceCluster(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/two_instance_cluster",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	// Retries are used because RDS proxy will sometimes fail to attach to newly created clusters (timing issue)
	maxRetries := 3
	sleepBetweenRetries := 5 * time.Second
	retry.DoWithRetry(t, "Create RDS resources", maxRetries, sleepBetweenRetries, func() (string, error) {
		return terraform.InitAndApplyE(t, terraformOptions)
	})
}
