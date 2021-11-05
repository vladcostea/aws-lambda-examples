resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  role             = aws_iam_role.role.arn
  handler          = "main"
  runtime          = "go1.x"
  timeout          = var.timeout
  memory_size      = var.memory_size
  s3_bucket        = "aws-lambda-examples-83a53dab073f4f7c"
  s3_key           = "lambda/${var.function_name}.zip"

  dynamic "dead_letter_config" {
    for_each = var.dlq_arn != "" ? [1]: []
    content {
      target_arn = var.dlq_arn
    }
  }

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
  override_json = var.policy_doc_json

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

  dynamic "statement" {
    for_each = var.dlq_arn != "" ? [1]: [] 
    content {
      actions = [
        "sqs:SendMessage"
      ]

      resources = [
        var.dlq_arn
      ]
    }
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

output "role_name" {
  value = aws_iam_role.role.name
}

output "arn" {
  value = aws_lambda_function.function.arn
}

output "invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.function.function_name
}
