# Contributing to invenio-oauthclient-aaf

Thank you for considering contributing to this project! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful and inclusive. We welcome contributions from everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub with:

- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (Python version, InvenioRDM version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:

- A clear description of the enhancement
- Why it would be useful
- Any implementation ideas you have

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Install development dependencies**:
   ```bash
   just install-dev
   ```
3. **Make your changes**
4. **Add tests** for any new functionality
5. **Run tests** to ensure everything passes:
   ```bash
   just test
   ```
6. **Format your code**:
   ```bash
   just format
   ```
7. **Run linters**:
   ```bash
   just lint
   ```
8. **Commit your changes** with a clear commit message
9. **Push to your fork** and submit a pull request

## Development Setup

### Prerequisites

- Python 3.9 or higher
- uv and just installed (for task management)

### Setting up development environment

```bash
# Clone your fork
git clone https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf.git
cd invenio-oauthclient-aaf

# Create virtual environment
just create-venv
just activate-venv

# Install development dependencies
just install-dev
```

### Running tests

```bash
# Run all tests
just test

# Run tests with coverage
just test-cov

# Run specific test file
pytest tests/test_handlers.py

# Run specific test
pytest tests/test_handlers.py::TestAccountInfo::test_account_info_success
```

### Code style

We use:

- **ruff** for code formatting and linting

Format your code before committing:

```bash
just format
```

Check code style:

```bash
just lint
```

## Project Structure

```
invenio-oauthclient-aaf/
├── invenio_oauthclient_aaf/    # Main package
│   ├── __init__.py              # Package initialization
│   ├── handlers.py              # OAuth handlers
│   └── remote.py                # Remote app configuration
├── tests/                       # Test files
│   ├── conftest.py              # Pytest configuration and fixtures
│   ├── test_handlers.py         # Handler tests
│   └── test_remote.py           # Remote configuration tests
├── docs/                        # Documentation
│   ├── README.md                # Documentation index
│   ├── QUICKSTART.md            # Quick start guide
│   ├── USAGE_EXAMPLES.md        # Usage examples
│   ├── JUSTFILE_GUIDE.md        # Guide for using justfile
│   ├── PACKAGE_STRUCTURE.md     # Package structure details
│   ├── MODERNIZATION.md         # Modernization notes
│   └── SEMANTIC_RELEASE.md      # Semantic release guide
├── scripts/                     # Utility scripts
│   ├── setup_dev.sh             # Development setup script
├── .github/                     # GitHub configuration
│   ├── workflows/               # CI/CD workflows
│   └── SEMANTIC_RELEASE_CHEATSHEET.md
├── README.md                    # Main project documentation
├── CONTRIBUTING.md              # Contribution guidelines
├── CHANGELOG.md                 # Version changelog
├── RELEASE.md                   # Release guide
├── PUBLISHING.md                # Publishing guide
├── setup.py                     # Package setup configuration
├── pyproject.toml               # Modern Python project configuration
├── justfile                     # Command runner (recommended)
├── Makefile                     # Legacy make commands
├── pytest.ini                   # Pytest configuration
├── .pre-commit-config.yaml      # Pre-commit hooks
└── uv.lock                      # UV package lock file
```

## Writing Tests

- Place tests in the `tests/` directory
- Name test files with `test_` prefix
- Name test functions with `test_` prefix
- Use descriptive test names
- Aim for high test coverage (>90%)

Example test:

```python
def test_account_info_success():
   """Test successful user info retrieval."""
   # Arrange
   remote = Mock()
   resp = {"access_token": "test_token"}

   # Act
   result = account_info(remote, resp)

   # Assert
   assert result["user"]["email"] == "expected@email.com"
```

## Commit Messages

Write clear, concise commit messages:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- First line should be 50 characters or less
- Reference issues and pull requests when relevant

Examples:

```
Add support for custom attribute mapping
Fix user info retrieval for missing username
Update documentation for sandbox configuration
```

## Documentation

- Update README.md for user-facing changes
- Add docstrings to new functions/classes

## Questions?

If you have questions, feel free to:

- Open an issue on GitHub
- Contact the maintainers

Thank you for contributing!
