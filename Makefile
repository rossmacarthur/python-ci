VIRTUAL_ENV := $(or $(VIRTUAL_ENV), $(VIRTUAL_ENV), venv)

.PHONY: help
help: ## Show this message and exit.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## Remove all build artifacts.
	rm -rf build dist wheels
	find . \( -name *.pyc -o -name *.pyo -o -name __pycache__ -o -name *.egg-info \) -exec rm -rf {} +

.PHONY: install
install: ## Install package.
	$(VIRTUAL_ENV)/bin/pip install -e .

.PHONY: install-dev
install-dev: ## Install package and linting and testing dependencies.
	$(VIRTUAL_ENV)/bin/pip install -e ".[dev.lint,dev.test]"

.PHONY: install-all
install-all: install-dev ## Install package and all development dependencies.
	$(VIRTUAL_ENV)/bin/pip install twine

.PHONY: lint
lint: ## Run all lints.
	$(VIRTUAL_ENV)/bin/flake8 --max-complexity 10 .

.PHONY: sort-imports
sort-imports: ## Sort import statements according to isort configuration.
	$(VIRTUAL_ENV)/bin/isort --recursive .

.PHONY: test
test: ## Run all tests.
	$(VIRTUAL_ENV)/bin/pytest -vv --cov=ci --cov-report term-missing test_ci.py

.PHONY: dist
dist: clean ## Build source and wheel package.
	$(VIRTUAL_ENV)/bin/python setup.py sdist bdist_wheel

.PHONY: release
release: dist ## Package and upload a release.
	$(VIRTUAL_ENV)/bin/twine upload dist/*
