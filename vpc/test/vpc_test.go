package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/stretchr/testify/require"
)

type naclRule struct {
	from   string
	to     string
	action string
}

// Gets a VPCs internet gateway
func GetVpcInternetGateways(t *testing.T, client *ec2.EC2, vpcId string) *ec2.DescribeInternetGatewaysOutput {
	igwFilter := ec2.Filter{Name: aws.String("attachment.vpc-id"), Values: []*string{&vpcId}}

	igws, err := client.DescribeInternetGateways(&ec2.DescribeInternetGatewaysInput{Filters: []*ec2.Filter{&igwFilter}})
	require.NoError(t, err)

	return igws
}

// Gets a VPCs NAT gateways
func GetVpcNatGateways(t *testing.T, client *ec2.EC2, vpcId string) *ec2.DescribeNatGatewaysOutput {
	vpcFilter := ec2.Filter{Name: aws.String("vpc-id"), Values: []*string{&vpcId}}

	natGateways, err := client.DescribeNatGateways(&ec2.DescribeNatGatewaysInput{Filter: []*ec2.Filter{&vpcFilter}})
	require.NoError(t, err)

	return natGateways
}

// Gets the NACLs for a VPC, filtered by rule
func GetVpcNetworkAcls(t *testing.T, client *ec2.EC2, vpcId string, naclRules *[]naclRule) *ec2.DescribeNetworkAclsOutput {
	filters := make([]*ec2.Filter, 0)
	filters = append(filters, &ec2.Filter{Name: aws.String("vpc-id"), Values: []*string{&vpcId}})

	for _, rule := range *naclRules {
		filters = append(filters, &ec2.Filter{Name: aws.String("entry.port-range.from"), Values: []*string{&rule.from}})
		filters = append(filters, &ec2.Filter{Name: aws.String("entry.port-range.to"), Values: []*string{&rule.to}})
		filters = append(filters, &ec2.Filter{Name: aws.String("entry.rule-action"), Values: []*string{&rule.action}})
	}

	networkAcls, err := client.DescribeNetworkAcls(&ec2.DescribeNetworkAclsInput{Filters: filters})
	require.NoError(t, err)

	return networkAcls
}

// Gets a VPCs flow log
func GetVpcFlowLogs(t *testing.T, client *ec2.EC2, logGroupName string) *ec2.DescribeFlowLogsOutput {
	flowLogsFilter := ec2.Filter{Name: aws.String("log-group-name"), Values: []*string{&logGroupName}}

	flowLogs, err := client.DescribeFlowLogs(&ec2.DescribeFlowLogsInput{Filter: []*ec2.Filter{&flowLogsFilter}})
	require.NoError(t, err)

	return flowLogs
}
