.PHONY: build

build:
	GOOS=linux GOARCH=amd64 go build -o ./build/main .

test: build
	go test