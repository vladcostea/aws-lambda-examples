terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "random_id" "s3_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3_trigger" {
  bucket = "aws-lambda-examples-${random_id.s3_bucket_id.hex}"
}