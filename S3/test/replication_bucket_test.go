package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestReplicationBucketCreation(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/replication_bucket",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs from the `terraform apply`
	source_bucket_id := terraform.Output(t, terraformOptions, "source_bucket_id")
	destination_bucket_arn := terraform.Output(t, terraformOptions, "destination_bucket_arn")
	replication_role_arn := terraform.Output(t, terraformOptions, "replication_role_arn")

	// Test the public access block
	s3Client := aws.NewS3Client(t, region)
	req, resp := s3Client.GetBucketReplicationRequest(&s3.GetBucketReplicationInput{Bucket: &source_bucket_id})
	require.NoError(t, req.Send())

	assert.Equal(t, replication_role_arn, *resp.ReplicationConfiguration.Role)
	assert.Equal(t, destination_bucket_arn, *resp.ReplicationConfiguration.Rules[0].Destination.Bucket)
}
