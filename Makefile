.PHONY: help install install-dev test test-cov lint format clean build upload sync

help:
	@echo "Available commands:"
	@echo "  install      - Install package with uv"
	@echo "  install-dev  - Install package with development dependencies"
	@echo "  sync         - Sync dependencies from uv.lock"
	@echo "  test         - Run tests"
	@echo "  test-cov     - Run tests with coverage report"
	@echo "  lint         - Run linters (ruff)"
	@echo "  format       - Format code with ruff"
	@echo "  clean        - Remove build artifacts"
	@echo "  build        - Build distribution packages with uv"
	@echo "  upload       - Upload to PyPI with uv"
	@echo "  upload-test  - Upload to TestPyPI with uv"

install:
	uv pip install -e .

install-dev:
	uv pip install -e ".[tests]"

sync:
	uv sync

test:
	uv run pytest

test-cov:
	uv run pytest --cov=invenio_oauthclient_aaf --cov-report=html --cov-report=term
	@echo "Coverage report: htmlcov/index.html"

lint:
	uv run ruff check invenio_oauthclient_aaf tests

format:
	uv run ruff format invenio_oauthclient_aaf tests
	uv run ruff check --fix invenio_oauthclient_aaf tests

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf htmlcov/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf .ruff_cache/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

build: clean
	uv build

upload: build
	uv publish

upload-test: build
	uv publish --publish-url https://test.pypi.org/legacy/
