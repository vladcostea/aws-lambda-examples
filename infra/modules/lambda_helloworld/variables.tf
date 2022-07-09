variable "aws_region" {
  type = string
}

variable "aws_account" {
  type = string
}

variable "function_name" {
  type = string
}

variable "timeout" {
  type    = number
  default = 5
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "policy_doc_json" {
  type    = string
  default = "{}"
}

variable "build_artifacts" {
  type = string
}