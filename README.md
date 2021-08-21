# AWS Lambda async invocation patterns

## SQS as event source

To trigger an event with SQS:

```
aws sqs send-message --queue-url QUEUE_URL --message-body "some message"
```

## S3 as event source

```
aws s3 cp FILE s3://BUCKET_ID/KEY
```

## DynamoDB Streams as event source

```
aws dynamodb put-item \
    --table-name dynamo_streams_trigger \
    --item '{"pk":{"S":"123"},"sk":{"S":"456"}}'
```

## TODO

- AWS XRay
- Add SNS as an event source
- Example SNS to multiple SQS queues

## References:

- https://data.solita.fi/lessons-learned-from-combining-sqs-and-lambda-in-a-data-project/
- https://aws.amazon.com/blogs/compute/operating-lambda-application-design-part-3
- https://stackoverflow.com/questions/52581618/sqs-lambda-retry-logic
- https://aws.amazon.com/blogs/compute/designing-durable-serverless-apps-with-dlqs-for-amazon-sns-amazon-sqs-aws-lambda/