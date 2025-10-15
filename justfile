# justfile for invenio-oauthclient-aaf
# Modern task runner - https://github.com/casey/just
#
# Install just: https://just.systems/install
#   macOS:   brew install just
#   Cargo:   cargo install just
#   Script:  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
#
# Usage:
#   just          - List all available commands
#   just setup    - Setup development environment
#   just test     - Run tests
#   just release  - Create automated release

# Load .env file if it exists
set dotenv-load := true

# List all available commands (default)
default:
    @just --list

# Show this help message
help:
    @echo "invenio-oauthclient-aaf - Task Runner"
    @echo ""
    @echo "Common commands:"
    @echo "  just setup         Setup development environment"
    @echo "  just test          Run tests"
    @echo "  just commit        Interactive commit (conventional)"
    @echo "  just release       Create automated release"
    @echo ""
    @echo "All commands:"
    @just --list

# ============================================================================
# Setup & Installation
# ============================================================================

# Setup complete development environment (recommended for first time)
setup:
    @echo "🚀 Setting up development environment..."
    uv pip install -e ".[dev]"
    uv run pre-commit install
    uv run pre-commit install --hook-type commit-msg
    @echo "✅ Development environment ready!"
    @echo ""
    @echo "Next steps:"
    @echo "  just test          # Run tests"
    @echo "  just commit        # Make a commit"
    @echo "  just --list        # See all commands"

# Install package with uv
install:
    uv pip install -e .

# Install package with development dependencies
install-dev:
    uv pip install -e ".[dev]"

# Install package with test dependencies only
install-test:
    uv pip install -e ".[tests]"

# Sync dependencies from uv.lock
sync:
    uv sync

# Update dependencies
update:
    uv sync --upgrade

# Create virtual environment
create-venv:
    uv venv

# Show activation instructions
activate-venv:
    @echo "To activate the virtual environment, run:"
    @echo "source .venv/bin/activate"

# ============================================================================
# Testing & Quality
# ============================================================================

# Run tests
test:
    uv run pytest

# Run tests with coverage report
test-cov:
    uv run pytest --cov=invenio_oauthclient_aaf --cov-report=html --cov-report=term --cov-report=xml
    @echo "Coverage report: htmlcov/index.html"

# Generate coverage report and open in browser
coverage: test-cov
    @echo "Opening coverage report..."
    @open htmlcov/index.html || xdg-open htmlcov/index.html || start htmlcov/index.html

# Watch for changes and run tests
watch:
    uv run pytest-watch

# Run linters (ruff check)
lint:
    uv run ruff check invenio_oauthclient_aaf tests

# Format code with ruff and auto-fix issues
format:
    uv run ruff format invenio_oauthclient_aaf tests
    uv run ruff check --fix invenio_oauthclient_aaf tests

# Run all quality checks (lint + test)
check: lint test

# Full CI pipeline (format, lint, test, build)
ci: format lint test-cov build
    @echo "✅ All CI checks passed!"

# ============================================================================
# Pre-commit Hooks
# ============================================================================

# Install pre-commit hooks
setup-hooks:
    uv run pre-commit install
    uv run pre-commit install --hook-type commit-msg
    @echo "✅ Pre-commit hooks installed!"

# Run pre-commit on all files
pre-commit-all:
    uv run pre-commit run --all-files

# Update pre-commit hooks to latest versions
update-hooks:
    uv run pre-commit autoupdate

# ============================================================================
# Building & Publishing
# ============================================================================

# Remove build artifacts and cache files
clean:
    rm -rf build/ dist/ *.egg-info htmlcov/ .pytest_cache/ .coverage .ruff_cache/
    find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete

# Build distribution packages with uv
build: clean
    uv build

# Show package info
info:
    uv pip show invenio-oauthclient-aaf

# Check for outdated dependencies
outdated:
    uv pip list --outdated

# ============================================================================
# Release Management (Semantic Release - RECOMMENDED)
# ============================================================================

# Interactive commit with commitizen (use this for commits!)
commit:
    uv run cz commit

# Check what the next version would be
version-check:
    uv run semantic-release version --print

# Show what the release would do (verbose)
version-dry:
    @echo "ℹ️  Showing what the next release would contain:"
    @echo ""
    uv run semantic-release version --print
    @echo ""
    @echo "Run 'just release' to create the release"

# Bump version and create changelog (local only, no push)
version:
    uv run semantic-release version --no-push --no-vcs-release

# Bump version, create changelog, and commit (but don't push)
version-commit:
    uv run semantic-release version --no-push

# Create a full release (version + tag + changelog + GitHub release)
release:
    @echo "🚀 Creating automated release..."
    @echo ""
    uv run semantic-release version
    @echo ""
    @echo "✅ Release complete!"
    @echo "   - Version bumped in pyproject.toml"
    @echo "   - CHANGELOG.md updated"
    @echo "   - Git tag created and pushed"
    @echo "   - GitHub release created"

# Generate/update changelog only
changelog:
    uv run semantic-release changelog

# ============================================================================
# Manual Publishing (NOT RECOMMENDED - use 'just release' instead)
# ============================================================================

# Manual upload to PyPI with uv (deprecated - use 'just release' instead)
publish-manual: build
    @echo ""
    @echo "⚠️  WARNING: Manual publishing is deprecated!"
    @echo "   Consider using 'just release' for automated releases"
    @echo "   This ensures:"
    @echo "     - Proper version bumping"
    @echo "     - Changelog generation"
    @echo "     - Git tagging"
    @echo "     - GitHub release creation"
    @echo ""
    @read -p "Continue with manual publish? [y/N] " confirm && [ "$$confirm" = "y" ]
    uv publish

# Manual upload to TestPyPI with uv
publish-test-manual: build
    @echo "Publishing to TestPyPI manually..."
    uv publish --publish-url https://test.pypi.org/legacy/
