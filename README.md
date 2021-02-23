# AWS Lambda async invocation patterns

## SQS as event source

To trigger an event with SQS:

```
aws sqs send-message --queue-url QUEUE_URL --message-body "some message"
```

References:

- https://data.solita.fi/lessons-learned-from-combining-sqs-and-lambda-in-a-data-project/
- https://aws.amazon.com/blogs/compute/operating-lambda-application-design-part-3
- https://stackoverflow.com/questions/52581618/sqs-lambda-retry-logic
- https://aws.amazon.com/blogs/compute/designing-durable-serverless-apps-with-dlqs-for-amazon-sns-amazon-sqs-aws-lambda/