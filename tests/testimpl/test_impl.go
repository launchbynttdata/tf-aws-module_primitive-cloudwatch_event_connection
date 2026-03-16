package testimpl

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eventbridge"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	opts := ctx.TerratestTerraformOptions()

	connectionName := terraform.Output(t, opts, "name")
	connectionArn := terraform.Output(t, opts, "arn")
	connectionID := terraform.Output(t, opts, "id")
	secretArn := terraform.Output(t, opts, "secret_arn")

	require.NotEmpty(t, connectionName, "connection name should be set")
	require.NotEmpty(t, connectionArn, "connection ARN should be set")
	assert.Equal(t, connectionName, connectionID, "id should equal name for EventBridge connections")

	cfg, err := config.LoadDefaultConfig(context.Background())
	require.NoError(t, err, "failed to load AWS config")

	client := eventbridge.NewFromConfig(cfg)
	result, err := client.DescribeConnection(context.Background(), &eventbridge.DescribeConnectionInput{
		Name: aws.String(connectionName),
	})
	require.NoError(t, err, "connection should exist in EventBridge API")
	require.NotNil(t, result, "DescribeConnection should return a result")

	assert.Equal(t, connectionName, aws.ToString(result.Name), "connection name should match")
	assert.Equal(t, "API_KEY", string(result.AuthorizationType), "authorization type should be API_KEY")

	require.NotNil(t, result.SecretArn, "secret ARN should be set (credentials stored in Secrets Manager)")
	assert.Equal(t, secretArn, aws.ToString(result.SecretArn), "secret ARN should match Terraform output")
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	opts := ctx.TerratestTerraformOptions()

	connectionName := terraform.Output(t, opts, "name")
	connectionArn := terraform.Output(t, opts, "arn")
	secretArn := terraform.Output(t, opts, "secret_arn")

	require.NotEmpty(t, connectionName, "connection name should be set")
	require.NotEmpty(t, connectionArn, "connection ARN should be set")

	cfg, err := config.LoadDefaultConfig(context.Background())
	require.NoError(t, err, "failed to load AWS config")

	client := eventbridge.NewFromConfig(cfg)
	result, err := client.DescribeConnection(context.Background(), &eventbridge.DescribeConnectionInput{
		Name: aws.String(connectionName),
	})
	require.NoError(t, err, "connection should exist in EventBridge API")
	require.NotNil(t, result, "DescribeConnection should return a result")

	assert.Equal(t, connectionName, aws.ToString(result.Name), "connection name should match")
	assert.Equal(t, "API_KEY", string(result.AuthorizationType), "authorization type should be API_KEY")
	assert.Equal(t, secretArn, aws.ToString(result.SecretArn), "secret ARN should match Terraform output")
}
