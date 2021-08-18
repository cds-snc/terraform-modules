package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestHighAvailabilityVpc(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/high_availability",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcId, region)

	// 3 private + 3 public subnet
	assert.Equal(t, 6, len(vpc.Subnets))

	// Expect 3 unique AZs
	availabilityZones := make(map[string]bool)
	for _, subnet := range vpc.Subnets {
		if !availabilityZones[subnet.AvailabilityZone] {
			availabilityZones[subnet.AvailabilityZone] = true
		}
	}
	assert.Equal(t, 3, len(availabilityZones))

	// EC2 client to check for resources
	client := aws.NewEc2Client(t, region)

	igws := GetVpcInternetGateways(t, client, vpcId)
	assert.Equal(t, 1, len(igws.InternetGateways))

	nats := GetVpcNatGateways(t, client, vpcId)
	assert.Equal(t, 3, len(nats.NatGateways))

	nacls := GetVpcDenyNetworkAcls(t, client, vpcId)
	assert.Equal(t, 0, len(nacls.NetworkAcls))

	flowLogs := GetVpcFlowLogs(t, client, "high_availability_flow_logs")
	assert.Equal(t, 1, len(flowLogs.FlowLogs))
}
