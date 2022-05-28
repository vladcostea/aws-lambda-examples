terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_sqs_queue" "s3_trigger_failures" {
  name = "s3_trigger_failures"
}

resource "random_id" "s3_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3_trigger" {
  bucket = "s3-trigger-${random_id.s3_bucket_id.hex}"
}

module "lambda_s3_trigger" {
  aws_account = var.aws_account
  aws_region  = var.aws_region

  source = "../terraform/modules/lambda_go"

  function_name = "s3_trigger"

  timeout         = 30
  memory_size     = 1024
  policy_doc_json = data.aws_iam_policy_document.s3_trigger_on_failure.json
}

data "aws_iam_policy_document" "s3_trigger_on_failure" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.s3_trigger_failures.arn
    ]
  }
}

resource "aws_lambda_function_event_invoke_config" "s3_trigger_invoke_config" {
  function_name = module.lambda_s3_trigger.function_name

  destination_config {
    on_failure {
      destination = aws_sqs_queue.s3_trigger_failures.arn
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_s3_trigger.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_trigger.arn
}


resource "aws_s3_bucket_notification" "s3_trigger_bucket_notification" {
  bucket = aws_s3_bucket.s3_trigger.id

  lambda_function {
    lambda_function_arn = module.lambda_s3_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}