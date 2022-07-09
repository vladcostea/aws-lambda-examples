SHELL := /bin/bash

.PHONY: build

build:
	mkdir -p build
	GOOS=linux GOARCH=amd64 go build -o build ./lambda/...
