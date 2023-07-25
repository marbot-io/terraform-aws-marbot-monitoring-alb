package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func configALB(t *testing.T) *terraform.Options {
	albPath := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/alb")

	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: albPath,
	})
}
