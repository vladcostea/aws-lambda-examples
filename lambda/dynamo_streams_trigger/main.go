package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, ev events.DynamoDBEvent) error {
	for _, message := range ev.Records {
		if testField, ok := message.Change.NewImage["test_field"]; ok {
			if testField.String() == "error" {
				return errors.New("failed event")
			}
		}
		messageJSON, _ := json.Marshal(message)
		log.Println(string(messageJSON))
	}

	log.Printf("handled %d messages\n", len(ev.Records))
	return nil
}
