SHELL := /bin/bash

build:
	@GOOS=linux GOARCH=amd64 go build -o ./dist/lambda/$(function)/main ./$(function)
	@cd dist/lambda/$(function) && zip -9qyr $(function).zip main

deploy: build
	@aws lambda update-function-code \
	  --function-name $(function) \
	  --zip-file fileb://dist/lambda/$(function)/$(function).zip
