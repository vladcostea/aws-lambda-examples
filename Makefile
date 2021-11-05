SHELL := /bin/bash

build:
	@GOOS=linux GOARCH=amd64 go build -o ./dist/lambda/$(function)/main ./$(function)
	@cd dist/lambda/$(function) && zip -9qyr $(function).zip main

upload_s3:
	@aws s3api put-object \
  	--bucket aws-lambda-examples-83a53dab073f4f7c \
  	--key lambda/$(function).zip \
  	--body ./dist/lambda/$(function)/$(function).zip

deploy: build
	@aws lambda update-function-code \
	  --function-name $(function) \
	  --zip-file fileb://dist/lambda/$(function)/$(function).zip
