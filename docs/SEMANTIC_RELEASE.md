# Semantic Release Guide

This project uses `python-semantic-release` for automated version management and releases.

## Quick Start

### Daily Development Workflow

```bash
# 1. Make your changes
# Edit files...

# 2. Stage changes
git add .

# 3. Create conventional commit (interactive)
just commit
# Or manually: git commit -m "feat: add new feature"

# 4. Push changes
git push
```

### Creating a Release

```bash
# Check what version will be created
just version-check

# Create new version, update changelog, and create GitHub release
just release

# Or do it step by step:
just version      # Bump version + update changelog
git push --follow-tags
```

---

## Conventional Commits

Semantic release analyzes your commit messages to determine version bumps.

### Commit Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types and Version Impact

| Type        | Version Bump      | Example                               |
| ----------- | ----------------- | ------------------------------------- |
| `feat:`     | **Minor** (0.x.0) | `feat: add OAuth scope configuration` |
| `fix:`      | **Patch** (0.0.x) | `fix: handle expired token refresh`   |
| `perf:`     | **Patch** (0.0.x) | `perf: optimize token validation`     |
| `refactor:` | **Patch** (0.0.x) | `refactor: simplify handler logic`    |
| `docs:`     | **None**          | `docs: update installation guide`     |
| `style:`    | **None**          | `style: format with ruff`             |
| `test:`     | **None**          | `test: add handler tests`             |
| `build:`    | **None**          | `build: update dependencies`          |
| `ci:`       | **None**          | `ci: fix workflow permissions`        |
| `chore:`    | **None**          | `chore: update pre-commit hooks`      |

### Breaking Changes (Major version)

Add `BREAKING CHANGE:` in commit body or `!` after type:

```bash
# Method 1: Using footer
git commit -m "feat: change OAuth handler signature

BREAKING CHANGE: handler now requires additional context parameter"

# Method 2: Using ! in type
git commit -m "feat!: redesign authentication flow"
```

This creates a **Major** version bump (x.0.0).

---

## Using Commitizen (Interactive Commits)

Commitizen helps you write correct conventional commits:

```bash
# Interactive commit wizard
just commit

# Or directly:
cz commit
```

You'll be prompted:

```
? Select the type of change you are committing: (Use arrow keys)
  feat: A new feature
  fix: A bug fix
  docs: Documentation only changes
  style: Changes that don't affect code meaning
  refactor: Code change that neither fixes a bug nor adds a feature
  perf: A code change that improves performance
  test: Adding missing tests
  build: Changes to the build system
  ci: Changes to CI configuration
  chore: Other changes that don't modify src/test files

? What is the scope of this change? (optional): handlers
? Write a short description: add token refresh support
? Provide a longer description: (optional)
? Are there any breaking changes? No
? Does this change affect any open issues? No
```

Result: `feat(handlers): add token refresh support`

---

## Semantic Release Commands

### Check Next Version

See what version will be created based on commits:

```bash
just version-check

# Output:
# Current version: 0.10.3
# Next version: 0.11.0
# Reason: feat commits found
```

### Dry Run

Test the release process without making changes:

```bash
just version-dry

# Shows:
# - What version will be created
# - What commits will be included
# - What changelog entries will be added
```

### Version Bump

Update version in files and create changelog:

```bash
just version

# This will:
# 1. Analyze commits since last release
# 2. Determine version bump
# 3. Update version in pyproject.toml
# 4. Update CHANGELOG.md
# 5. Create git commit
# 6. Create git tag
```

Then push:

```bash
git push --follow-tags
```

### Full Release

Do everything in one command:

```bash
just release

# This will:
# 1. Run `semantic-release version`
# 2. Push commits and tags
# 3. Create GitHub release with changelog
```

### Generate Changelog Only

```bash
just changelog

# Updates CHANGELOG.md without changing version
```

---

## Complete Release Workflow

### Example: Feature Release

```bash
# 1. Develop features (multiple commits)
git commit -m "feat: add AAF sandbox support"
git commit -m "feat: add custom scope configuration"
git commit -m "docs: update configuration examples"
git commit -m "test: add integration tests"

# 2. Check what version will be created
just version-check
# Output: 0.10.3 → 0.11.0 (minor bump due to feat commits)

# 3. Create release
just release

# Done! Version 0.11.0 is now:
# - Tagged in git
# - Published on GitHub
# - Documented in CHANGELOG.md
```

### Example: Bug Fix Release

```bash
# 1. Fix bug
git commit -m "fix: correct token expiry calculation"

# 2. Check version
just version-check
# Output: 0.11.0 → 0.11.1 (patch bump)

# 3. Release
just release
```

### Example: Breaking Change Release

```bash
# 1. Make breaking change
git commit -m "feat!: redesign handler interface

BREAKING CHANGE: handlers now receive RemoteApp instance"

# 2. Check version
just version-check
# Output: 0.11.1 → 1.0.0 (major bump!)

# 3. Release
just release
```

---

## Integration with Existing Workflow

Semantic release works alongside your existing GitHub Actions publish workflow:

```
1. Make commits (conventional format)
   ↓
2. Run: just release
   ↓
3. Semantic-release creates:
   - Version bump commit
   - Git tag (e.g., v0.11.0)
   - GitHub release
   ↓
4. Your publish.yml workflow triggers automatically
   ↓
5. Package published to PyPI
```

---

## Configuration

Configuration is in [`pyproject.toml`](../pyproject.toml):

```toml
[tool.semantic_release]
version_toml = ["pyproject.toml:project.version"]
branch = "main"
build_command = "uv build"
upload_to_vcs_release = true  # Create GitHub releases
upload_to_pypi = false         # Let GitHub Actions handle PyPI
```

### Key Settings:

- **`upload_to_pypi = false`**: We use the existing GitHub Actions workflow for PyPI
- **`upload_to_vcs_release = true`**: Creates GitHub releases with changelog
- **`build_command`**: Command to build the package (for verification)

---

## Troubleshooting

### "No release will be made"

**Cause:** No commits since last release that trigger a version bump.

**Solution:** Make sure commits use conventional format (`feat:`, `fix:`, etc.)

```bash
# Check commit history
git log --oneline v0.10.3..HEAD

# Look for conventional commits
```

### Version in multiple files out of sync

**Cause:** Manual version edits.

**Solution:** Let semantic-release manage versions:

```bash
# Check configured version files
grep -A 5 "tool.semantic_release" pyproject.toml

# Reset to last release and use semantic-release
git checkout v0.10.3 -- pyproject.toml
just version
```

### Changelog not updating

**Cause:** Changelog configuration issue or no conventional commits.

**Solution:**

```bash
# Regenerate changelog
just changelog

# Or force regenerate from all tags
semantic-release changelog --unreleased
```

### GitHub release not created

**Cause:** Authentication or permission issue.

**Solution:**

```bash
# Make sure you have GitHub CLI authenticated
gh auth status

# Or set GITHUB_TOKEN environment variable
export GITHUB_TOKEN="your-token"
just release
```

---

## Best Practices

### 1. Use Commitizen for Commits

```bash
# Instead of:
git commit -m "added feature"

# Use:
just commit
# (interactive wizard ensures correct format)
```

### 2. Check Before Releasing

```bash
# Always check what will happen
just version-check
just version-dry

# Then release
just release
```

### 3. Write Meaningful Commit Messages

```bash
# ❌ Bad
git commit -m "fix: bug"

# ✅ Good
git commit -m "fix: correct token refresh timing issue

Tokens were being refreshed too early, causing unnecessary
API calls. Now refresh only when token has <5min remaining."
```

### 4. Use Scopes for Organization

```bash
git commit -m "feat(handlers): add custom error handling"
git commit -m "fix(remote): correct OAuth redirect URL"
git commit -m "docs(readme): add configuration examples"
```

### 5. Test Before Major Releases

```bash
# For breaking changes, test thoroughly
just test
just lint
just build

# Then release
just release
```

---

## Reference

### Conventional Commit Spec

- https://www.conventionalcommits.org/

### Python Semantic Release Docs

- https://python-semantic-release.readthedocs.io/

### Commitizen Docs

- https://commitizen-tools.github.io/commitizen/

---

## Quick Command Reference

| Command              | Description                             |
| -------------------- | --------------------------------------- |
| `just commit`        | Interactive conventional commit         |
| `just version-check` | Show next version                       |
| `just version-dry`   | Dry run release process                 |
| `just version`       | Bump version and update changelog       |
| `just release`       | Full release (version + GitHub release) |
| `just changelog`     | Update changelog only                   |
| `cz bump`            | Alternative: Commitizen version bump    |

---

## Migration from Manual Releases

If you've been creating releases manually:

1. **Install dependencies:**

   ```bash
   just setup
   ```

2. **Test with dry run:**

   ```bash
   just version-dry
   ```

3. **Create first automated release:**

   ```bash
   just release
   ```

4. **Update your workflow:**
   - Keep using conventional commits
   - Use `just release` instead of manual tagging
   - GitHub Actions publish workflow still runs automatically
