package tests

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestInfraPlanCompleto(t *testing.T) {
	t.Parallel()

	tfOptions := &terraform.Options{
		TerraformDir: "../", // ruta al root del proyecto
		Upgrade:      true,
		NoColor:      true,
		VarFiles:     []string{"default.auto.tfvars"},
	}

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// Validar que se genera el plan correctamente
	assert.NotNil(t, plan.ResourcePlannedValuesMap)

	// Verificar recursos clave
	expectedResources := []string{
		"aws_glue_job.main",
		"aws_glue_crawler.main",
		"aws_s3_bucket.main",
		"aws_redshift_cluster.main",
		"aws_secretsmanager_secret.db1_credentials",
		"aws_glue_connection.db1",
		"aws_glue_connection.redshift",
		"aws_sfn_state_machine.etl_orchestration",
	}

	for _, resource := range expectedResources {
		_, found := plan.ResourcePlannedValuesMap[resource]
		assert.True(t, found, "Falta recurso: %s", resource)
	}

	// Validar comunicación entre módulos (ej: que outputs estén presentes)
	outputs := terraform.OutputAll(t, tfOptions)
	assert.Contains(t, outputs, "glue_job_name")
	assert.Contains(t, outputs, "crawler_name")
	assert.Contains(t, outputs, "staging_bucket_arn")
}
