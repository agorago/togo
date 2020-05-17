
include .env

# Pre-requisites for running this Makefile
# Make sure that go is installed
# Make sure that go get golang.org/x/tools/cmd/stringer is executed to install the stringer tool
# For docker related builds make sure that docker is installed
# For swagger generation make sure go-swagger is installed.
# brew tap go-swagger/go-swagger
# brew install go-swagger

.DEFAULT_GOAL := all


## create-bin: create the bin directory if it doesnt exist
.PHONY: create-bin
create-bin:
	if [ ! -d bin ]; then mkdir bin; fi

## build: Build the executable
.PHONY: build
build: create-bin
	go build -ldflags "-X 'main.Version=$(VERSION)'" -o bin/main cmd/main/main.go

## run: Run the executable after building it
.PHONY: run
run:
	go run cmd/main/main.go

## run-main: Run the executable after building it
.PHONY: run-main
run-main: create-bin prepare-dependencies build
	bin/main

## docker-build: Builds a container  using docker 
.PHONY: docker-build
docker-build:
	docker build -t sample -f internal/deploy/Dockerfile ..

## docker-run: RUNS the docker container built using docker-build 
.PHONY: docker-run
docker-run:
	docker run -p 8080:8080 sample

## prepare-dependencies: Prepares the dependencies from dependencies.txt
.PHONY: prepare-dependencies
prepare-dependencies: generate-error-codes generate-dependencies-go copy-bundles

## copy-tests: Copies the feature test files from all dependencies
.PHONY: copy-tests
copy-tests: 
	${TOGODIR}/scripts/prepare-dependencies/copy-tests.sh

## generate-main-test-go: Generates the main test file. Makes sure that it invokes all modules
.PHONY: generate-main-test-go
generate-main-test-go: 
	${TOGODIR}/scripts/prepare-dependencies/generate-main-test-go.sh

# generate-dependencies-go: Generates the dependencies.go file from dependencies.txt
.PHONY: generate-dependencies-go
generate-dependencies-go: 
	${TOGODIR}/scripts/prepare-dependencies/generate-dependencies-go.sh
	 
# This is an internal task invoked by the prepare-dependencies and does not need to appear as a
# help line. Hence there is only one pound in the comment.
# copy-bundles: Copies the bundle files from individual modules to a common CONFIG folder
.PHONY: copy-bundles
copy-bundles:
	${TOGODIR}/scripts/prepare-dependencies/copy-bundles.sh

# generate-error-codes: Generates error codes from enum constants (using iota)
.PHONY: generate-error-codes
generate-error-codes:
	${TOGODIR}/scripts/prepare-dependencies/gen-error.sh


## test-scripts: Execute all tests from command line
.PHONY: test-scripts
test-scripts:
	internal/scripts/test/test.sh

## test: execute the BDD tests
.PHONY: test
test: 
	go test -v ./... --godog.format=pretty -race -coverprofile=bin/coverage.txt -covermode=atomic

## build-linux: Build the binary for Linux
.PHONY: build-linux
build-linux:
	@echo "Building for linux"
	GOOS=linux GOARCH=arm go build -o bin/main-linux-arm main.go
	GOOS=linux GOARCH=arm64 go build -o bin/main-linux-arm64 main.go

## swagger-gen-build: Build the swagger generator.
.PHONY: swagger-gen-build
swagger-gen-build: create-bin
	@echo "Building swagger-gen executable"
	go build -o bin/swagger-gen internal/cmd/swagger-gen/swagger-gen-main.go

## swagger-docs:Use the swagger-gen generator to build the swagger docs.
.PHONY: swagger-docs
swagger-docs: swagger-gen-build
	@echo "Building swagger documentation for the service"
	${TOGODIR}/scripts/swagger/swagger-generate.sh

## swagger-build: Build the swagger.yaml file from the doc specification
.PHONY: swagger-build
swagger-build:
	@echo "Building swagger.yaml spec file"
	swagger generate spec -o ./swagger.yaml --scan-models

## swagger-serve: Serves the Swagger spec file via the swagger UI
.PHONY: swagger-serve
swagger-serve: swagger-build
	@echo "Serving swagger"
	swagger serve -F=swagger swagger.yaml

# check-tag: internal tag does not need to show in documentation
.PHONY: check-tag
check-tag:
	@ if ! test -n "$(tag)"; then echo "tag needs to be specified. Use 'make $(MAKECMDGOALS) tag=<tagname>'"; exit 1 ; fi

## tag: Tag the source with tag name xxx. Use "make tag tag=<tagname>"
.PHONY: tag
tag: check-tag
	git tag -a -m $(tag) $(tag)
	@echo "Created a  tag $(tag) for the release. Now you can run 'make build'"

## create-hotfix: Creates a hotfix branch for tag xxx. Use it like "make create-hotfix tag=<tagname>"
.PHONY: create-hotfix
create-hotfix: check-tag
	git checkout -b b$(tag) $(tag)
	@echo "Created a hotfix branch b$(tag) and checked it out for you"

## increment-major: Increment the Major version number
.PHONY: increment-major
increment-major:
	@$(TOGODIR)/scripts/release/increment-tag.sh major

## increment-minor: Increment the Minor version number
.PHONY: increment-minor
increment-minor:
	@$(TOGODIR)/scripts/release/increment-tag.sh minor

## increment-patch: Increment the Patch version number
.PHONY: increment-patch
increment-patch:
	@$(TOGODIR)/scripts/release/increment-tag.sh patch

## create-hotfix-latest: Creates a hotfix for the latest tag
.PHONY: create-hotfix-latest
create-hotfix-latest:
	@$(TOGODIR)/scripts/release/make-hotfix-branch.sh


## find-latest-local-tag: Finds the latest tag for this project
.PHONY: find-latest-local-tag
find-latest-local-tag:
	@git describe | cut -d- -f1

## merge-master: Merge the hotfix branch with master. Before this make sure that the hotifx has been tagged and released
.PHONY: merge-master
merge-master:
	@$(TOGODIR)/scripts/release/merge-hotfix-to-master.sh

## list-local-tags: List all the tags in origin
.PHONY: list-local-tags
list-local-tags:
	@git tag

## list-origin-tags: List all the tags in origin
.PHONY: list-origin-tags
list-origin-tags:
	@git ls-remote --tags origin | grep -v '\}' | cut -d/ -f3

## delete-origin-tag: Delete a tag at the origin
.PHONY: delete-origin-tag
delete-origin-tag: check-tag
	git push --delete origin $(tag)

## delete-local-tag: Delete a local tag
.PHONY: delete-local-tag
delete-local-tag: check-tag
	git tag -d $(tag)

.PHONY: all
all: help

## help: type for getting this help
.PHONY: help
help: Makefile
	@echo 
	@echo " Choose a command to run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
