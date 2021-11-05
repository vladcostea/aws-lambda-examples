terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "lambda_helloworld" {
  aws_account = var.aws_account
  aws_region  = var.aws_region

  source = "../terraform/modules/lambda_go_s3"

  function_name = "helloworld"

  timeout         = 30
  memory_size     = 1024
}

variable "aws_account" {
  type = string
}

variable "aws_region" {
  type = string
}
