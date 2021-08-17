package test

import (
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

	// EC2 client to check for resources
	client := aws.NewEc2Client(t, region)

	// Check for Internet Gateway
	internetGatewayFilter := ec2.Filter{Name: awssdk.String("attachment.vpc-id"), Values: []*string{&vpcId}}
	internetGateway, errIgw := client.DescribeInternetGateways(&ec2.DescribeInternetGatewaysInput{Filters: []*ec2.Filter{&internetGatewayFilter}})
	require.NoError(t, errIgw)
	assert.Equal(t, 1, len(internetGateway.InternetGateways))

	// Check for NAT Gateway
	natGatewayFilter := ec2.Filter{Name: awssdk.String("vpc-id"), Values: []*string{&vpcId}}
	natGateway, errNat := client.DescribeNatGateways(&ec2.DescribeNatGatewaysInput{Filter: []*ec2.Filter{&natGatewayFilter}})
	require.NoError(t, errNat)
	assert.Equal(t, 1, len(natGateway.NatGateways))

	// Check NACL for rules blocking SSH and RDP
	naclVpcFilter := ec2.Filter{Name: awssdk.String("vpc-id"), Values: []*string{&vpcId}}
	naclPortSshFilter := ec2.Filter{Name: awssdk.String("entry.port-range.from"), Values: []*string{awssdk.String("22")}}
	naclPortRdpFilter := ec2.Filter{Name: awssdk.String("entry.port-range.from"), Values: []*string{awssdk.String("3389")}}
	nacls, errNacl := client.DescribeNetworkAcls(&ec2.DescribeNetworkAclsInput{Filters: []*ec2.Filter{&naclVpcFilter, &naclPortSshFilter, &naclPortRdpFilter}})
	require.NoError(t, errNacl)
	assert.Equal(t, 1, len(nacls.NetworkAcls))

	// Check no VPC flow logs
	flowLogsFilter := ec2.Filter{Name: awssdk.String("log-group-name"), Values: []*string{awssdk.String("single_zone_flow_logs")}}
	flowLogs, errFlowLogs := client.DescribeFlowLogs(&ec2.DescribeFlowLogsInput{Filter: []*ec2.Filter{&flowLogsFilter}})
	require.NoError(t, errFlowLogs)
	assert.Equal(t, 0, len(flowLogs.FlowLogs))
}
