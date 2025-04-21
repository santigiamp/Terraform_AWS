package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGlobalPlan_Offline(t *testing.T) {
	t.Parallel()

	options := &terraform.Options{
		TerraformDir: "/home/santino-giampietro/ProyectoMVP Cliente Objetivo 1/brainboard-Prueba-6-",
		NoColor:      true,

		// Variables si es necesario cargarlas desde un .tfvars
		VarFiles: []string{"terraform.tfvars"},

		// Para evitar que pregunte nada
		EnvVars: map[string]string{
			"AWS_PROFILE": "vscode-dev", // o el nombre que corresponda
		},
	}

	// Capturamos ambos valores: el estado y el error
	_, initErr := terraform.InitE(t, options)
	assert.NoError(t, initErr)

	// Capturamos ambos valores: el estado y el error
	_, planErr := terraform.PlanE(t, options)
	assert.NoError(t, planErr)
}
