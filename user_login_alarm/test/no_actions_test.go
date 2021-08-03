package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNoActionAlarmCreations(t *testing.T) {
	t.Parallel()

	accountNames := [2]string{"ops1", "ops2"}
	alarmFailThreshold := 3.0
	alarmSuccessThreshold := 1.0
	metricNamespace := "terratest"
	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/no_actions",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Check expected Success/Failure alarms were created with expected thresholds
	client := NewCloudWatchClient(t, region)
	for _, account := range accountNames {
		metricName := account + "_ConsoleLogin_Success"
		alarmSuccess := GetMetricAlarm(t, client, metricName, metricNamespace).MetricAlarms[0]

		assert.Equal(t, metricName+"_alarm_success", *alarmSuccess.AlarmName)
		assert.Equal(t, alarmSuccessThreshold, *alarmSuccess.Threshold)
		assert.Equal(t, 0, len(alarmSuccess.AlarmActions))

		metricName = account + "_ConsoleLogin_Failure"
		alarmFail := GetMetricAlarm(t, client, metricName, metricNamespace).MetricAlarms[0]

		assert.Equal(t, metricName+"_alarm_failure", *alarmFail.AlarmName)
		assert.Equal(t, alarmFailThreshold, *alarmFail.Threshold)
		assert.Equal(t, 0, len(alarmFail.AlarmActions))
	}
}
