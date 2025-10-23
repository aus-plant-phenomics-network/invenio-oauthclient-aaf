#!/bin/bash
# Development environment setup script for invenio-oauthclient-aaf
# Modern setup using uv for fast dependency management

set -e

echo "🚀 Setting up development environment for invenio-oauthclient-aaf"
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv not found. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "✅ uv is already installed"
fi

# Check Python version
echo "📋 Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "   Python version: $python_version"

# Create virtual environment with uv if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "🔧 Creating virtual environment with uv..."
    uv venv
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# Install package in development mode with test dependencies using uv
echo "📦 Installing package with test dependencies using uv..."
uv pip install -e ".[tests]"

# Install development tools (ruff is already in pyproject.toml)
echo "🛠️  Development tools (ruff) included in dependencies"

# Sync dependencies from lockfile if it exists
if [ -f "uv.lock" ]; then
    echo "🔄 Syncing dependencies from uv.lock..."
    uv sync
fi

# Run tests to verify installation
echo "🧪 Running tests..."
uv run pytest

# Display summary
echo ""
echo "✨ Setup complete!"
echo ""
echo "📚 Modern tooling in use:"
echo "  ⚡ uv      - Fast Python package manager"
echo "  🔍 ruff    - Fast linter and formatter"
echo ""
echo "Available commands:"
echo "  just test        - Run tests"
echo "  just test-cov    - Run tests with coverage"
echo "  just lint        - Run ruff linter"
echo "  just format      - Format code with ruff"
echo "  just sync        - Sync dependencies from uv.lock"
echo "  just build       - Build package with uv"
echo "  just clean       - Clean build artifacts"
echo ""
echo "To activate the virtual environment in the future:"
echo "  source .venv/bin/activate"
echo ""
echo "Happy coding! 🎉"
