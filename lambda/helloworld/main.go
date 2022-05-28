package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context) (response, error) {
	return response{Message: "Hello"}, nil
}

type response struct {
	Message string `json:"message"`
}
