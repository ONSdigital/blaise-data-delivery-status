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
	@poetry run flake8 --max-line-length=88 .

.PHONY: test
## Run full test suite
test:
	@echo "Running full test suite (unit tests, integration tests and behave tests)"
	@poetry run python -m behave --format=progress2 tests/features
	@$$(gcloud beta emulators datastore env-init) && poetry run python -m pytest

.PHONY: test-unit
## Run unit tests without integration tests
test-unit:
	@echo "Running unit tests"
	@poetry run python -m pytest

.PHONY: test-integration
## Run the integration tests
test-integration:
	@echo "Running integration tests"
	@echo "Please ensure that you have run 'make start-datastore-emulator' in a separate terminal window before running 'make test-integration'"
	@$$(gcloud beta emulators datastore env-init) && poetry run python -m pytest -m "integration_test"

.PHONY: test-behave
## Run behave tests 
test-behave:
	@echo "Running unit tests"
	@poetry run python -m behave --format=progress2 tests/features

.PHONY: install-datastore-emulator
## Install Datastore emulator
install-datastore-emulator:
	@echo "Installing Datastore emulator"
	@gcloud components install cloud-datastore-emulator

.PHONY: start-datastore-emulator
## Start Datastore emulator
start-datastore-emulator: install-datastore-emulator
	@echo "Starting Datastore emulator"
	@gcloud beta emulators datastore start --no-store-on-disk