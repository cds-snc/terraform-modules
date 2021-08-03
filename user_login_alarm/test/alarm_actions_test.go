package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestActionsAlarmCreations(t *testing.T) {
	t.Parallel()

	accountName := "samwise"
	alarmFailThreshold := 5.0
	alarmSuccessThreshold := 1.0
	metricNamespace := "terratest"
	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/alarm_actions",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs from the `terraform apply`
	snsSuccessArn := terraform.Output(t, terraformOptions, "sns_topic_success_arn")
	snsFailureArn := terraform.Output(t, terraformOptions, "sns_topic_failure_arn")

	client := NewCloudWatchClient(t, region)

	// Validate Success alarm
	metricName := accountName + "_ConsoleLogin_Success"
	alarmSuccess := GetMetricAlarm(t, client, metricName, metricNamespace).MetricAlarms[0]

	assert.Equal(t, metricName+"_alarm_success", *alarmSuccess.AlarmName)
	assert.Equal(t, alarmSuccessThreshold, *alarmSuccess.Threshold)
	assert.Equal(t, 1, len(alarmSuccess.AlarmActions))
	assert.Equal(t, snsSuccessArn, *alarmSuccess.AlarmActions[0])

	// Validate Failure alarm
	metricName = accountName + "_ConsoleLogin_Failure"
	alarmFail := GetMetricAlarm(t, client, metricName, metricNamespace).MetricAlarms[0]

	assert.Equal(t, metricName+"_alarm_failure", *alarmFail.AlarmName)
	assert.Equal(t, alarmFailThreshold, *alarmFail.Threshold)
	assert.Equal(t, 1, len(alarmFail.AlarmActions))
	assert.Equal(t, snsFailureArn, *alarmFail.AlarmActions[0])
}
