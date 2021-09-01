package test

import (
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/service/rds"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPostgresqlCluster(t *testing.T) {
	t.Parallel()

	region := "ca-central-1"
	clusterName := "postgresql-cluster"
	proxyName := "postgresql-proxy"
	logGroupName := "/aws/rds/proxy/" + proxyName

	// The RDS proxy is flaky and will sometimes not attach properly due to the
	// cluster being in an unexpected state.  These retries give things time to settle down.
	maxRetries := 3
	timeBetweenRetries := 10 * time.Second
	retryableTerraformErrors := map[string]string{
		".*error registering RDS DB Proxy.*": "Failed to register RDS DB proxy",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/postgresql_cluster",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		MaxRetries:               maxRetries,
		TimeBetweenRetries:       timeBetweenRetries,
		RetryableTerraformErrors: retryableTerraformErrors,
	}

	// Destroy resource once tests are finished
	defer terraform.Destroy(t, terraformOptions)

	// Create the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get Terraform outputs
	privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	rdsClusterId := terraform.Output(t, terraformOptions, "rds_cluster_id")
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")

	// AWS clients to check the resources
	rdsClient := aws.NewRdsClient(t, region)
	cloudwatchClient := aws.NewCloudWatchLogsClient(t, region)

	// Check the cluster
	clusters, errClusters := rdsClient.DescribeDBClusters(&rds.DescribeDBClustersInput{DBClusterIdentifier: &rdsClusterId})
	require.NoError(t, errClusters)

	cluster := clusters.DBClusters[0]
	assert.Equal(t, 1, len(clusters.DBClusters))
	assert.Equal(t, 2, len(cluster.DBClusterMembers))
	assert.Equal(t, 3, len(cluster.AvailabilityZones))
	assert.Equal(t, int64(1), *cluster.BackupRetentionPeriod)
	assert.Equal(t, "terratest", *cluster.DatabaseName)
	assert.Equal(t, "thebigcheese", *cluster.MasterUsername)
	assert.Equal(t, "aurora-postgresql", *cluster.Engine)
	assert.Equal(t, "default.aurora-postgresql11", *cluster.DBClusterParameterGroup)
	assert.Equal(t, "01:00-03:00", *cluster.PreferredBackupWindow)
	assert.Equal(t, false, *cluster.DeletionProtection)
	assert.Equal(t, true, *cluster.StorageEncrypted)
	assert.Equal(t, true, *cluster.MultiAZ)

	// Check the RDS proxy
	proxies, errProxies := rdsClient.DescribeDBProxies(&rds.DescribeDBProxiesInput{DBProxyName: &proxyName})
	require.NoError(t, errProxies)

	proxy := proxies.DBProxies[0]
	assert.Equal(t, 1, len(proxies.DBProxies))
	assert.Equal(t, "POSTGRESQL", *proxy.EngineFamily)
	assert.Equal(t, "SECRETS", *proxy.Auth[0].AuthScheme)
	assert.Equal(t, "DISABLED", *proxy.Auth[0].IAMAuth)
	assert.Equal(t, int64(1800), *proxy.IdleClientTimeout)
	assert.Equal(t, true, *proxy.RequireTLS)
	assert.Equal(t, vpcId, *proxy.VpcId)

	// Check the proxy is attached to the 3 private subnet IDs
	proxySubnetIds := make([]string, len(proxy.VpcSubnetIds))
	for idx, subnetId := range proxy.VpcSubnetIds {
		proxySubnetIds[idx] = *subnetId
	}
	sort.Strings(proxySubnetIds)
	sort.Strings(privateSubnetIds)
	strings.Join(proxySubnetIds, ",")
	strings.Join(privateSubnetIds, ",")
	assert.Equal(t, privateSubnetIds, proxySubnetIds)

	// Check the RDS proxy targets
	proxyTargets, errProxyTargets := rdsClient.DescribeDBProxyTargets(&rds.DescribeDBProxyTargetsInput{DBProxyName: &proxyName})
	require.NoError(t, errProxyTargets)

	// 1 tracked cluster + 2 instances
	assert.Equal(t, 3, len(proxyTargets.Targets))
	for _, target := range proxyTargets.Targets {
		if target.TrackedClusterId != nil {
			assert.Equal(t, clusterName, *target.TrackedClusterId)
		} else {
			assert.Equal(t, clusterName, *target.RdsResourceId)
		}
	}

	// Check the CloudWatch log group
	logGroups, errLogGroups := cloudwatchClient.DescribeLogGroups(&cloudwatchlogs.DescribeLogGroupsInput{LogGroupNamePrefix: &logGroupName})
	require.NoError(t, errLogGroups)
	assert.Equal(t, 1, len(logGroups.LogGroups))
	assert.Equal(t, int64(14), *logGroups.LogGroups[0].RetentionInDays)
}
