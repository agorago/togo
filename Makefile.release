
# Pre-requisites for running this Makefile
# Make sure that git is installed
# install gradle
# install java (of course)

export PROJECTNAME="pricedomain"
.DEFAULT_GOAL := help

## build: Build the executable with the version extracted from GIT
.PHONY: build
build:
	gradle build

## clean: Clean files
.PHONY: clean
clean:
	gradle clean

## run: Run the executable using the Application plugin
.PHONY: run
run:
	gradle run

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
	@scripts/increment-tag.sh major

## increment-minor: Increment the Minor version number
.PHONY: increment-minor
increment-minor:
	@scripts/increment-tag.sh minor

## increment-patch: Increment the Patch version number
.PHONY: increment-patch
increment-patch:
	@scripts/increment-tag.sh patch

## create-hotfix-latest: Creates a hotfix for the latest tag
.PHONY: create-hotfix-latest
create-hotfix-latest:
	@scripts/make-hotfix-branch.sh


## find-latest-local-tag: Finds the latest tag for this project
.PHONY: find-latest-local-tag
find-latest-local-tag:
	@git describe | cut -d- -f1

## merge-master: Merge the hotfix branch with master. Before this make sure that the hotifx has been tagged and released
.PHONY: merge-master
merge-master:
	@scripts/merge-hotfix-to-master.sh

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

## help: type for getting this help
.PHONY: help
help: Makefile
	@echo
	@echo " Choose a command to run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
