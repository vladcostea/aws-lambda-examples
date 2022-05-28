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

func handler(ctx context.Context, ev events.S3Event) error {
	for _, message := range ev.Records {
		if message.S3.Object.Key == "error" {
			return errors.New("failed from event")
		}

		messageJSON, _ := json.Marshal(message)
		log.Println(string(messageJSON))
	}

	log.Printf("handled %d messages\n", len(ev.Records))
	return nil
}
