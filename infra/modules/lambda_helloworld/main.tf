terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }

    archive = {
      source = "hashicorp/archive"
      version = "~> 2"
    }
  }
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${var.build_path}/helloworld"
  output_path = "${var.build_path}/helloworld.zip"
}

resource "aws_s3_object" "lambda_package" {
  bucket = var.build_artifacts
  key = "lambda/${var.function_name}.zip"
  source = data.archive_file.lambda_zip.output_path
  etag = data.archive_file.lambda_zip.output_md5
}

resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  role             = aws_iam_role.role.arn
  handler          = "helloworld"
  runtime          = "go1.x"
  timeout          = var.timeout
  memory_size      = var.memory_size
  s3_bucket        = var.build_artifacts
  s3_key           = aws_s3_object.lambda_package.key
  tracing_config {
    mode = "Active"
  }
}

resource "aws_iam_role" "role" {
  name = "lambda_${var.function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "policy_doc" {
  override_policy_documents = [var.policy_doc_json]

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account}:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/${var.function_name}:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "policy" {
  name   = "lambda_${var.function_name}"
  policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_xray_write_only_access" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
