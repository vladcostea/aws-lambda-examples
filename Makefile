SHELL := /bin/bash

.PHONY: build

build:
	@GOOS=linux GOARCH=amd64 go build -o ./build/lambda/$(function)/main ./lambda/$(function)
	@cd build/lambda/$(function) && zip -9qyr $(function).zip main

upload_s3: build
	@aws s3api put-object \
  	--bucket $(BUILD_ARTIFACTS_BUCKET) \
  	--key lambda/$(prefix)$(function).zip \
  	--body ./build/lambda/$(function)/$(function).zip

deploy: upload_s3
	@aws lambda update-function-code \
	  --function-name $(function) \
	  --s3-bucket $(BUILD_ARTIFACTS_BUCKET) \
		--s3-key lambda/$(prefix)$(function).zip
