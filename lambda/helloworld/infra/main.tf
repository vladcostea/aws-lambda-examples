module "lambda_helloworld" {
  source = "../../../infra/modules/lambda_go_s3_v2"

  aws_account     = var.aws_account
  aws_region      = var.aws_region
  build_artifacts = var.build_artifacts
  function_name   = "${var.prefix}helloworld"
}

variable "aws_account" {
  type = string
}

variable "aws_region" {
  type = string
  default = "eu-west-1"
}
variable "build_artifacts" {
  type = string
}

variable "prefix" {
  type = string
  default = null
}