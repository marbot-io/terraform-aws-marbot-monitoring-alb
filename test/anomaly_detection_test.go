package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAnomalyDetection(t *testing.T) {
	t.Parallel()

	albOptions := configALB(t)

	defer terraform.Destroy(t, albOptions)
	terraform.InitAndApply(t, albOptions)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/anomaly_detection",
		Vars: map[string]interface{}{
			"endpoint_id":           os.Getenv("MARBOT_ENDPOINT_ID"),
			"loadbalancer_fullname": terraform.Output(t, albOptions, "loadbalancer_fullname"),
			"targetgroup_fullname":  terraform.Output(t, albOptions, "targetgroup_fullname"),
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
