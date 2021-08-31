package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSingleZoneVpc(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"
	availabilityZone := region + "a"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/single_zone",
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

	// 1 private + 1 public subnet
	assert.Equal(t, 2, len(vpc.Subnets))
	for _, subnet := range vpc.Subnets {
		assert.Equal(t, availabilityZone, subnet.AvailabilityZone)
	}

	// EC2 client to check for resource
	client := aws.NewEc2Client(t, region)

	igws := GetVpcInternetGateways(t, client, vpcId)
	assert.Equal(t, 1, len(igws.InternetGateways))

	nats := GetVpcNatGateways(t, client, vpcId)
	assert.Equal(t, 1, len(nats.NatGateways))

	// Expect NACL rules to exist for blocking SSH, RDP
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
	assert.Equal(t, 1, len(naclsDeny.NetworkAcls))

	// Expect NACL rules to not exist for allowing HTTPS traffic
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
	assert.Equal(t, 0, len(naclsAllow.NetworkAcls))

	flowLogs := GetVpcFlowLogs(t, client, "single_zone_flow_logs")
	assert.Equal(t, 0, len(flowLogs.FlowLogs))
}
