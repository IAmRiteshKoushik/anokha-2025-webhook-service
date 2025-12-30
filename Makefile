build:
	@go fmt ./...
	@go build -o bin/tentacloid

run: build
	@./bin/tentacloid

woc:
	@bash scripts/insert_woc_data.sh
