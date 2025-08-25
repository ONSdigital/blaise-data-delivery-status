mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: show-help
## This help screen
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

.PHONY: format
## Format python
format:
	@poetry run black .
	@poetry run isort .

.PHONY: lint
## Run styling checks for python
lint:
	@poetry run black --check .
	@poetry run isort --check .
	@poetry run flake8 --max-line-length=120 . --exclude=tests

.PHONY: install-datastore-emulator
## Install Datastore emulator
install-datastore-emulator:
	@echo "Installing Datastore emulator"
	@gcloud components install cloud-datastore-emulator

.PHONY: start-datastore-emulator
## Start Datastore emulator
start-datastore-emulator:
	@echo "Starting Datastore emulator"
	@gcloud beta emulators datastore start --no-store-on-disk

.PHONY: test-unit
## Run unit tests without integration tests
test-unit:
	@echo "Running unit tests"
	@poetry run python -m pytest

.PHONY: test-behave
## Run behave tests 
test-behave:
	@echo "Running behavioural tests"
	@echo "Please ensure that the Datastore Emulator is running in a separate terminal window"
	@$$(gcloud beta emulators datastore env-init) && poetry run python -m behave --format=progress2 tests/features

.PHONY: test
## Run full test suite
test: test-unit test-behave
	@echo "Running full test suite"
	@echo "Please ensure that the Datastore Emulator is running in a separate terminal window"