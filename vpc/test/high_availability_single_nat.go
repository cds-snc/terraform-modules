package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestHighAvailabilityVpcSingleNat(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/high_availability_single_nat",
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
	assert.Equal(t, 1, len(nats.NatGateways))

	routes := GetVpcRouteTables(t, client, vpcId)
	assert.Equal(t, 4, len(routes.RouteTables))

	// Expect NACL rules to not exist for blocking SSH, RDP
	naclRulesDeny := []naclRule{
		{
			from:   "22",
			to:     "22",
			action: "deny",
		},
		{
			from:   "3389",
			to:     "3389",
			action: "deny",
		},
	}
	naclsDeny := GetVpcNetworkAcls(t, client, vpcId, &naclRulesDeny)
	assert.Equal(t, 0, len(naclsDeny.NetworkAcls))

	// Expect NACL rules to exist for allowing HTTPS traffic
	naclRulesAllow := []naclRule{
		{
			from:   "443",
			to:     "443",
			action: "allow",
		},
		{
			from:   "1024",
			to:     "65535",
			action: "allow",
		},
	}
	naclsAllow := GetVpcNetworkAcls(t, client, vpcId, &naclRulesAllow)
	assert.Equal(t, 1, len(naclsAllow.NetworkAcls))

	flowLogs := GetVpcFlowLogs(t, client, "high_availability_flow_logs")
	assert.Equal(t, 1, len(flowLogs.FlowLogs))
}
