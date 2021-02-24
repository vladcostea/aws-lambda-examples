terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "lambda_dynamo_streams_trigger" {
  aws_account = var.aws_account
  aws_region  = var.aws_region

  source = "../terraform/modules/lambda_go"

  function_name = "dynamo_streams_trigger"

  timeout         = 30
  memory_size     = 1024
  policy_doc_json = data.aws_iam_policy_document.dynamo_streams_trigger_doc.json
}

resource "aws_dynamodb_table" "lambda_trigger" {
  name = "dynamo_streams_trigger"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "pk"  
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

data "aws_iam_policy_document" "dynamo_streams_trigger_doc" {
  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]

    resources = [ 
      aws_dynamodb_table.lambda_trigger.stream_arn
    ]
  }

  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.dynamo_streams_trigger_failures.arn
    ]
  }
}

resource "aws_sqs_queue" "dynamo_streams_trigger_failures" {
  name = "dynamo_streams_trigger_failures"
}

resource "aws_lambda_event_source_mapping" "dynamo_trigger_mapping" {
  event_source_arn = aws_dynamodb_table.lambda_trigger.stream_arn
  function_name    = module.lambda_dynamo_streams_trigger.arn
  starting_position = "LATEST"
  maximum_retry_attempts = 2

  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.dynamo_streams_trigger_failures.arn
    }
  }
}