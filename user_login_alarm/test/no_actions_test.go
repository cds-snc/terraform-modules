package test

import (
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAlarmCreations(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"
	metricNamespace := "terratest"
	accountNames := [2]string{"ops1", "ops2"}

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/no_actions",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	client := NewCloudWatchClient(t, region)

	// Check expected Success/Failure alarms were created
	for _, account := range accountNames {
		metricName := account + "_ConsoleLogin_Success"
		alarmSuccess := GetMetricAlarm(t, client, metricName, metricNamespace)
		assert.Equal(t, metricName+"_alarm_success", *alarmSuccess.MetricAlarms[0].AlarmName)

		metricName = account + "_ConsoleLogin_Failure"
		alarmFail := GetMetricAlarm(t, client, metricName, metricNamespace)
		assert.Equal(t, metricName+"_alarm_failure", *alarmFail.MetricAlarms[0].AlarmName)
	}
}

// Retrieves the Alarms for a given metric and namespace
func GetMetricAlarm(t *testing.T, client *cloudwatch.CloudWatch, metricName string, metricNamespace string) *cloudwatch.DescribeAlarmsForMetricOutput {
	out, err := client.DescribeAlarmsForMetric(&cloudwatch.DescribeAlarmsForMetricInput{
		MetricName: awssdk.String(metricName),
		Namespace:  awssdk.String(metricNamespace),
	})
	if err != nil {
		t.Fatal(err)
	}
	return out
}

// Creates a new CloudWatch client
func NewCloudWatchClient(t *testing.T, region string) *cloudwatch.CloudWatch {
	sess, err := aws.NewAuthenticatedSession(region)
	if err != nil {
		t.Fatal(err)
	}
	return cloudwatch.New(sess)
}
