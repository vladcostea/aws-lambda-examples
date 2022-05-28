terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

resource "random_id" "s3_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "deploy_artifacts" {
  bucket = "${var.bucket_prefix}-${random_id.s3_bucket_id.hex}"
}

resource "aws_s3_bucket_versioning" "deploy_artifacts_versioning" {
  bucket = aws_s3_bucket.deploy_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.deploy_artifacts.id
  acl    = "private"
}