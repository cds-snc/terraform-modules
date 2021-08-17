package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLogBucketCreation(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"
	name := "totallyuniquecdslogbucket"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/log_bucket",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		Vars: map[string]interface{}{
			"name": name,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs from the `terraform apply`
	bucket_arn := terraform.Output(t, terraformOptions, "arn")
	bucket_id := terraform.Output(t, terraformOptions, "id")
	bucket_region := terraform.Output(t, terraformOptions, "region")

	assert.Equal(t, bucket_region, region)

	log_bucket_name := fmt.Sprintf("%s-log", name)
	arn := fmt.Sprintf("arn:aws:s3:::%s", log_bucket_name)
	assert.Equal(t, bucket_arn, arn)

	assert.Equal(t, bucket_id, log_bucket_name)
	assert.Equal(t, bucket_region, region)

}
