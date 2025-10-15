# Release Guide

This document contains the release process for `invenio-oauthclient-aaf` using **automated semantic-release**.

> 📖 **New to semantic-release?** See the [complete guide](docs/SEMANTIC_RELEASE.md) for detailed information.

---

## Quick Release (TL;DR)

```bash
# 1. Make sure all your commits follow conventional format
git log --oneline

# 2. Check what version will be created
just version-check

# 3. Create the release (automatic!)
just release
```

That's it! Everything else is automated. ✨

---

## Release Workflow

### Using Semantic Release (RECOMMENDED - Automated)

Semantic-release automatically handles:

- ✅ Version bumping based on commit messages
- ✅ Changelog generation
- ✅ Git tagging
- ✅ GitHub release creation
- ✅ PyPI publishing (via GitHub Actions)

**Workflow:**

```bash
# 1. Develop using conventional commits
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug"
git push

# 2. When ready to release
just version-check     # Preview next version
just release          # Create release

# 3. GitHub Actions automatically publishes to PyPI
# Check: https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/actions
```

**That's it!** No manual version bumping, no manual changelog, no manual tagging.

---

## Pre-Release Checklist

Before running `just release`, ensure:

### 1. Code Quality ✅

```bash
# All checks pass
just test           # Tests pass
just lint           # No linting errors
just ci             # Full CI pipeline passes
```

- [ ] All tests passing
- [ ] No linting errors
- [ ] Code coverage satisfactory
- [ ] CI/CD pipeline green

### 2. Commits Follow Conventional Format ✅

```bash
# Check recent commits
git log --oneline origin/main..HEAD

# Should see commits like:
# feat: add new OAuth scope support
# fix: handle token expiry correctly
# docs: update configuration examples
```

- [ ] All commits use conventional format (`feat:`, `fix:`, etc.)
- [ ] Breaking changes marked with `!` or `BREAKING CHANGE:`
- [ ] Commit messages are clear and descriptive

**Not using conventional commits yet?** Use:

```bash
just commit  # Interactive commit helper
```

### 3. Documentation ✅

- [ ] README.md updated if needed
- [ ] Breaking changes documented
- [ ] Migration guide provided (if breaking changes)

### 4. Testing ✅

```bash
# Optional: Test in actual InvenioRDM instance
cd /path/to/inveniordm-instance
uv pip install -e /path/to/invenio-oauthclient-aaf
invenio-cli services stop
invenio-cli services start
# Test login flow...
```

- [ ] Integration testing completed
- [ ] Login flow works
- [ ] No regressions

---

## Release Process

### Step 1: Preview the Release

```bash
# See what version will be created
just version-check

# Example output:
# Current version: 0.10.3
# Next version: 0.11.0  (due to feat commits)
# or
# Next version: 1.0.0   (due to BREAKING CHANGE)
```

**Version bumps are determined by commits:**

- `feat:` → Minor version (0.X.0)
- `fix:` → Patch version (0.0.X)
- `feat!:` or `BREAKING CHANGE:` → Major version (X.0.0)
- `docs:`, `test:`, `chore:` → No version bump

### Step 2: Create the Release

```bash
just release
```

**What happens automatically:**

1. ✅ Analyzes commits since last release
2. ✅ Determines version bump
3. ✅ Updates `pyproject.toml` version
4. ✅ Generates/updates `CHANGELOG.md`
5. ✅ Creates git commit
6. ✅ Creates git tag (e.g., `v0.11.0`)
7. ✅ Pushes commit and tag to GitHub
8. ✅ Creates GitHub release with changelog
9. ✅ Triggers `publish.yml` workflow
10. ✅ Publishes to PyPI via GitHub Actions

### Step 3: Verify

```bash
# Check GitHub release
open https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/releases

# Check PyPI (wait ~2-3 minutes for workflow)
open https://pypi.org/project/invenio-oauthclient-aaf/

# Check GitHub Actions
open https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/actions
```

**Verification checklist:**

- [ ] GitHub release created with correct changelog
- [ ] Git tag pushed to remote
- [ ] GitHub Actions workflow completed successfully
- [ ] Package published to PyPI
- [ ] Package metadata correct on PyPI
- [ ] README renders correctly on PyPI

### Step 4: Test Installation

```bash
# Create fresh environment
uv venv test-release
source test-release/bin/activate

# Install from PyPI
pip install invenio-oauthclient-aaf

# Verify version
python -c "import invenio_oauthclient_aaf; print(invenio_oauthclient_aaf.__version__)"
```

- [ ] Installs without errors
- [ ] Version matches release
- [ ] Package works correctly

---

## Pre-Release / Release Candidate

To create a pre-release for testing:

```bash
# 1. Use pre-release version format (with dash!)
# In pyproject.toml: version = "0.11.0-rc1"

# 2. Create pre-release tag
git tag v0.11.0-rc1
git push origin v0.11.0-rc1

# 3. Create GitHub pre-release
gh release create v0.11.0-rc1 \
  --title "v0.11.0-rc1" \
  --notes "Release candidate for testing" \
  --prerelease

# 4. GitHub Actions publishes to TestPyPI automatically
```

**Pre-release behavior:**

- Publishes to TestPyPI only (not production PyPI)
- Marked as pre-release on GitHub
- Won't trigger production publish workflow

---

## Manual Release (Fallback)

If semantic-release fails or you need manual control:

### Option 1: GitHub UI Release

```bash
# 1. Tag the release manually
git tag v0.11.0
git push origin v0.11.0

# 2. Create release on GitHub
# Go to: https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/releases/new
# - Select tag: v0.11.0
# - Write release notes
# - Click "Publish release"

# 3. GitHub Actions publishes to PyPI automatically
```

### Option 2: Full Manual (NOT RECOMMENDED)

```bash
# Build package
just build

# Upload to PyPI
just publish-manual
# (Will warn you and ask for confirmation)
```

See [PUBLISHING.md](PUBLISHING.md) for detailed manual publishing instructions.

---

## Post-Release

After successful release:

### Monitor

- [ ] Watch for issues from users
- [ ] Monitor download statistics: https://pypistats.org/packages/invenio-oauthclient-aaf
- [ ] Check for compatibility issues
- [ ] Review GitHub issues

---

## Troubleshooting

### "No release will be made"

**Cause:** No conventional commits since last release.

**Solution:**

```bash
# Check commits
git log --oneline v0.10.3..HEAD

# Ensure commits use conventional format
just commit  # Use interactive helper
```

### GitHub Actions Publish Failed

**Cause:** PyPI trusted publisher not configured or wrong permissions.

**Solution:**

1. Check GitHub Actions logs
2. Verify PyPI trusted publisher setup: https://pypi.org/manage/account/publishing/
3. Ensure workflow has correct permissions

### Package Already Exists on PyPI

**Cause:** Version already published (can't republish).

**Solution:**

1. Check what went wrong
2. Fix the issue
3. Bump to next patch version
4. Release again

### Wrong Version Created

**Cause:** Commit messages don't reflect the intended change.

**Solution:**

1. Don't panic - you can't delete from PyPI but you can:
2. Release a new version immediately with the fix
3. Or mark the version as "yanked" on PyPI (discourages but doesn't prevent installation)

---

## Version Strategy

We follow [Semantic Versioning](https://semver.org/):

**Given version MAJOR.MINOR.PATCH:**

- **MAJOR** (X.0.0): Breaking changes

  - API changes
  - Configuration changes
  - Requires user migration
  - Use `feat!:` or `BREAKING CHANGE:` in commit

- **MINOR** (0.X.0): New features

  - New functionality
  - Backward compatible
  - Use `feat:` in commit

- **PATCH** (0.0.X): Bug fixes
  - Bug fixes
  - Security patches
  - Documentation
  - Use `fix:`, `perf:`, `refactor:` in commit

**Examples:**

```
v0.10.3 → v0.10.4  (fix: bug)
v0.10.4 → v0.11.0  (feat: new feature)
v0.11.0 → v1.0.0   (feat!: breaking change)
```

---

## Emergency Procedures

### Critical Bug in Production

```bash
# 1. Fix on main branch
git checkout main
# ... fix the bug ...
git commit -m "fix: critical security issue in OAuth handler"

# 2. Immediate release
just version-check  # Should show patch bump
just release

# 3. Verify deployment
# Check PyPI and GitHub Actions
```

### Rollback Required

**You cannot delete from PyPI**, but you can:

1. **Yank the release** on PyPI (discourages installation):

   - Go to: https://pypi.org/project/invenio-oauthclient-aaf/
   - Click "Manage" → "Yank release"

2. **Release a fixed version immediately**:

   ```bash
   # Fix the issue
   git commit -m "fix: revert broken feature"
   just release  # Creates new patch version
   ```

3. **Communicate**:
   - Post warning on GitHub releases
   - Announce in community channels
   - Update documentation

---

## Quick Reference

### Common Commands

```bash
# Development
just commit           # Interactive conventional commit
just test            # Run tests
just ci              # Full CI pipeline

# Release
just version-check   # Preview next version
just release         # Create automated release

# Verification
just build           # Build package locally
just info            # Show package info
```

### Commit Types

| Type     | Version       | Example                   |
| -------- | ------------- | ------------------------- |
| `feat:`  | Minor (0.X.0) | `feat: add OAuth scopes`  |
| `fix:`   | Patch (0.0.X) | `fix: token expiry bug`   |
| `feat!:` | Major (X.0.0) | `feat!: redesign API`     |
| `docs:`  | None          | `docs: update README`     |
| `test:`  | None          | `test: add handler tests` |
| `chore:` | None          | `chore: update deps`      |

### Links

- **Semantic Release Guide**: [docs/SEMANTIC_RELEASE.md](docs/SEMANTIC_RELEASE.md)
- **Manual Publishing**: [PUBLISHING.md](PUBLISHING.md)
- **Contributing Guide**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Workflow File**: [.github/workflows/publish.yml](.github/workflows/publish.yml)

---

**Last Updated:** 2025-10-14
