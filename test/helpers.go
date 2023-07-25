package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func configALB(t *testing.T) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/alb",
	})
}
