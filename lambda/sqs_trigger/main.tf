terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "sqs_trigger_dlq"
}

resource "aws_sqs_queue" "sqs_trigger" {
  name = "sqs_trigger"

  # According to AWS best practices, the visibility timeout should be 6 times 
  # the timeout of the lambda function associated with this queue.
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = 180

  # Using the redrive policy we can set a dead letter queue for this SQS queue.
  # If a particular message appears maxReceiveCount times in the queue,
  # it will be discarded and sent to the DLQ for further processing.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount = 3
  })
}

module "lambda_sqs_trigger" {
  aws_account = var.aws_account
  aws_region  = var.aws_region

  source = "../terraform/modules/lambda_go"

  function_name = "sqs_trigger"

  timeout         = 30
  memory_size     = 1024
  policy_doc_json = data.aws_iam_policy_document.sqs_trigger_event_source_mapping.json
}

# https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-permissions
data "aws_iam_policy_document" "sqs_trigger_event_source_mapping" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.sqs_trigger.arn
    ]
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger_sqs" {
  event_source_arn = aws_sqs_queue.sqs_trigger.arn
  function_name    = module.lambda_sqs_trigger.arn
}

