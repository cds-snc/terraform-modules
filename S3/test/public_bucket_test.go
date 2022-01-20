package test

import (
	"fmt"
	"testing"

	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPublicBucketCreation(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/public_bucket",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
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

	arn := fmt.Sprintf("arn:aws:s3:::%s", bucket_id)
	assert.Equal(t, bucket_arn, arn)
	assert.Equal(t, bucket_region, region)

	// Test the public access block
	s3Client := aws.NewS3Client(t, region)
	reqAccess, respAccess := s3Client.GetPublicAccessBlockRequest(&s3.GetPublicAccessBlockInput{Bucket: &bucket_id})
	require.NoError(t, reqAccess.Send())

	assert.Equal(t, true, *respAccess.PublicAccessBlockConfiguration.BlockPublicAcls)
	assert.Equal(t, false, *respAccess.PublicAccessBlockConfiguration.BlockPublicPolicy)
	assert.Equal(t, true, *respAccess.PublicAccessBlockConfiguration.IgnorePublicAcls)
	assert.Equal(t, false, *respAccess.PublicAccessBlockConfiguration.RestrictPublicBuckets)

	reqEnc, respEnc := s3Client.GetBucketEncryptionRequest(&s3.GetBucketEncryptionInput{Bucket: &bucket_id})
	require.NoError(t, reqEnc.Send())

	assert.Equal(t, "AES256", *respEnc.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm)
}
