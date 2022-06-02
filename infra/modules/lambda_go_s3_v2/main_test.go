package main

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformHelloWorldExample(t *testing.T) {
	functionName := fmt.Sprintf("aws-lambda-examples-%s-helloworld", random.UniqueId())
	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"function_name": functionName,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	output := terraform.Output(t, opts, "function_name")
	if functionName != output {
		t.Fatalf("expected function name to be %s was %s", functionName, output)
	}

	response := aws.InvokeFunction(t, "eu-west-1", functionName, nil)
	var tr testResponse
	if err := json.Unmarshal(response, &tr); err != nil {
		t.Fatalf("expected no error when decoding response, got %v", err)
	}

	if tr.Message != "Hello" {
		t.Fatalf("expected function to respond with 'Hello', got %s", tr.Message)
	}
}

type testResponse struct {
	Message string `json:"message"`
}
