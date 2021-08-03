package test

import (
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/gruntwork-io/terratest/modules/aws"
)

// Retrieves the Alarms for a given metric and namespace
func GetMetricAlarm(t *testing.T, client *cloudwatch.CloudWatch, metricName string, metricNamespace string) *cloudwatch.DescribeAlarmsForMetricOutput {
	alarm, err := client.DescribeAlarmsForMetric(&cloudwatch.DescribeAlarmsForMetricInput{
		MetricName: awssdk.String(metricName),
		Namespace:  awssdk.String(metricNamespace),
	})
	if err != nil {
		t.Fatal(err)
	}
	return alarm
}

// Creates a new CloudWatch client
func NewCloudWatchClient(t *testing.T, region string) *cloudwatch.CloudWatch {
	sess, err := aws.NewAuthenticatedSession(region)
	if err != nil {
		t.Fatal(err)
	}
	return cloudwatch.New(sess)
}
