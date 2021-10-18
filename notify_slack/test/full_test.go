package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFull(t *testing.T) {
	t.Parallel()

	functionName := "notify_slack"
	region := "ca-central-1"
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/full",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	lambdaClient := aws.NewLambdaClient(t, region)

	// Test function
	lambdaFunction, errFunc := lambdaClient.GetFunction(&lambda.GetFunctionInput{FunctionName: &functionName})
	require.NoError(t, errFunc)
	assert.Equal(t, "Terratest", *lambdaFunction.Configuration.Environment.Variables["PROJECT_NAME"])
	assert.Equal(t, "https://your.slack.incoming.webhook.url", *lambdaFunction.Configuration.Environment.Variables["SLACK_WEBHOOK_URL"])

	// Test SNS permission policy
	lambdaPolicy, errPol := lambdaClient.GetPolicy(&lambda.GetPolicyInput{FunctionName: &functionName})
	require.NoError(t, errPol)
	lambdaArn := terraform.Output(t, terraformOptions, "lambda_arn")
	snsArn := terraform.Output(t, terraformOptions, "sns_arn")
	assert.Equal(t, true, strings.Contains(*lambdaPolicy.Policy, fmt.Sprintf("\"Resource\":\"%s\"", lambdaArn)))
	assert.Equal(t, true, strings.Contains(*lambdaPolicy.Policy, fmt.Sprintf("\"AWS:SourceArn\":\"%s\"", snsArn)))
}
