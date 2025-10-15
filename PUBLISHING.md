# Publishing Setup & Configuration

This guide covers the **one-time setup** for automated PyPI publishing and manual publishing options.

> 📖 **For releasing**: See [RELEASE.md](RELEASE.md) for the automated release workflow with semantic-release.

---

## Overview

This package uses:

- ✅ **Semantic-release** for automated version management and releases
- ✅ **GitHub Actions** for automated PyPI publishing
- ✅ **PyPI Trusted Publishers** for secure, token-free publishing

**Normal workflow:**

```bash
just release  # Everything automated!
```

This document covers the **setup** and **manual fallback options**.

---

## One-Time Setup

### 1. Configure PyPI Trusted Publisher (Required)

PyPI Trusted Publishers is the most secure method - no API tokens needed!

#### For Production PyPI:

1. **Create PyPI account** (if needed): https://pypi.org/account/register/
2. **Register trusted publisher**:

   - Go to: https://pypi.org/manage/account/publishing/
   - Click "Add a new pending publisher"
   - Fill in:
     - **PyPI Project Name**: `invenio-oauthclient-aaf`
     - **Owner**: Your GitHub username/org (e.g., `appn`)
     - **Repository name**: `invenio-oauthclient-aaf`
     - **Workflow name**: `publish.yml`
     - **Environment name**: `pypi`
   - Click "Add"

3. **Verify configuration**:
   - Project name matches exactly
   - Workflow filename is `publish.yml` (not `.github/workflows/publish.yml`)
   - Environment name is `pypi`

#### For TestPyPI (Optional but Recommended):

1. **Create TestPyPI account**: https://test.pypi.org/account/register/
2. **Register trusted publisher**:
   - Go to: https://test.pypi.org/manage/account/publishing/
   - Same process as above but:
     - **Environment name**: `testpypi`

**Why TestPyPI?**

- Test releases without affecting production
- Pre-releases automatically go here
- Safe to experiment

### 2. Configure GitHub Environments (Optional)

Add approval requirements or protection rules:

1. Go to: `https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/settings/environments`
2. Create environment named `pypi`:
   - (Optional) Add required reviewers for approval before publishing
   - (Optional) Add deployment branch rule: `main` only
3. Create environment named `testpypi` (optional):
   - No restrictions needed for testing

**Benefits:**

- Require manual approval before production releases
- Restrict publishing to specific branches
- Add deployment protection rules

### 3. Verify Workflow Permissions

Check that [.github/workflows/publish.yml](.github/workflows/publish.yml) has:

```yaml
permissions:
  contents: write # For creating GitHub releases
  id-token: write # For PyPI trusted publishing
```

These should already be configured correctly.

---

## How Automated Publishing Works

### The Complete Flow:

```
1. You run: just release
   ↓
2. Semantic-release:
   - Analyzes commits
   - Bumps version
   - Updates CHANGELOG.md
   - Creates git tag (e.g., v1.0.0)
   - Pushes to GitHub
   - Creates GitHub release
   ↓
3. GitHub Actions (publish.yml) triggers:
   - Builds package
   - Publishes to PyPI (via trusted publisher)
   - Uploads artifacts to GitHub release
   ↓
4. Done! Package on PyPI
```

### Pre-releases:

For pre-release versions (e.g., `v1.0.0-rc1`):

- Automatically published to **TestPyPI** only
- Not published to production PyPI
- Marked as pre-release on GitHub

---

## Versioning

Versions are managed automatically by semantic-release based on commit messages:

- `feat:` → **0.X.0** (minor)
- `fix:` → **0.0.X** (patch)
- `feat!:` or `BREAKING CHANGE:` → **X.0.0** (major)

See [RELEASE.md](RELEASE.md) for complete release workflow.

---

## Manual Publishing (Fallback Options)

If automated publishing fails or you need manual control:

### Option 1: Manual GitHub Release (Triggers Automation)

```bash
# 1. Ensure version is correct in pyproject.toml
# Edit: version = "1.0.0"

# 2. Commit and tag
git add pyproject.toml
git commit -m "chore: bump version to 1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0

# 3. Create GitHub release
gh release create v1.0.0 \
  --title "v1.0.0" \
  --notes "Release notes here"

# 4. GitHub Actions will publish to PyPI automatically
```

### Option 2: Manual PyPI Upload (Last Resort)

```bash
# 1. Build package
just build

# 2. Upload manually (will ask for confirmation)
just publish-manual

# Or directly with uv
uv publish
```

**When to use manual upload:**

- Automated publishing is broken
- Testing the package build locally
- Emergency hotfix needed immediately

**Warning:** Manual uploads bypass:

- Automated versioning
- Changelog generation
- CI/CD checks
- Trusted publisher security

### Option 3: Test on TestPyPI First

```bash
# Build and upload to TestPyPI
just publish-test-manual

# Or with uv
uv publish --publish-url https://test.pypi.org/legacy/

# Test installation
pip install --index-url https://test.pypi.org/simple/ \
   --extra-index-url https://pypi.org/simple/ \
   invenio-oauthclient-aaf
```

---

## Troubleshooting

### "Publisher not found" Error

**Cause:** PyPI trusted publisher not configured or misconfigured.

**Solution:**

1. Go to https://pypi.org/manage/account/publishing/
2. Verify the publisher exists with:
   - Correct repository name
   - Workflow name: `publish.yml` (not full path)
   - Environment name: `pypi`
3. If wrong, delete and recreate

### "Permission denied" Error

**Cause:** Workflow lacks required permissions.

**Solution:**

1. Check [.github/workflows/publish.yml](.github/workflows/publish.yml) has:
   ```yaml
   permissions:
     id-token: write
     contents: write
   ```
2. Verify GitHub environment is configured
3. Check repository settings → Actions → General → Workflow permissions

### "Package already exists" Error

**Cause:** Version already published to PyPI (can't republish same version).

**Solution:**

1. Bump version in `pyproject.toml`
2. Create new release
3. PyPI doesn't allow version reuse - this is by design

### Workflow Didn't Trigger

**Cause:** Workflow only triggers on GitHub releases, not tags alone.

**Solution:**

```bash
# Don't just push a tag - create a GitHub release:
git tag v1.0.0
git push origin v1.0.0
gh release create v1.0.0  # ← This triggers the workflow
```

### Package Missing Files

**Cause:** Files not included in build.

**Solution:**

1. Check files are tracked by git
2. Review `pyproject.toml` for any exclusions
3. Test build locally:
   ```bash
   just build
   tar -tzf dist/*.tar.gz  # Check contents
   ```

### TestPyPI Upload Failed

**Cause:** TestPyPI trusted publisher not configured.

**Solution:**

1. Set up trusted publisher on https://test.pypi.org/manage/account/publishing/
2. Use environment name: `testpypi`
3. Verify pre-release tag format: `v1.0.0-rc1` (dash, not dot)

---

## Using API Tokens (Alternative to Trusted Publishers)

If you can't use trusted publishers (e.g., organization restrictions):

### Setup:

1. **Create PyPI API token**:

   - Go to: https://pypi.org/manage/account/token/
   - Scope: Project-specific for `invenio-oauthclient-aaf`
   - Copy token (starts with `pypi-`)

2. **Add to GitHub Secrets**:

   - Go to: Repository Settings → Secrets and variables → Actions
   - New repository secret: `PYPI_API_TOKEN`
   - Paste token

3. **Update workflow** ([.github/workflows/publish.yml](.github/workflows/publish.yml)):

   ```yaml
   - name: Publish to PyPI
     uses: pypa/gh-action-pypi-publish@release/v1
     with:
       password: ${{ secrets.PYPI_API_TOKEN }}
   # Remove this section:
   # permissions:
   #   id-token: write
   ```

**Drawbacks:**

- Less secure than trusted publishers
- Tokens can leak or expire
- Need to manage token rotation
- PyPI recommends trusted publishers instead

---

## Verification Checklist

After setting up, verify:

- [ ] PyPI trusted publisher registered
- [ ] TestPyPI trusted publisher registered (optional)
- [ ] GitHub environments configured (optional)
- [ ] Workflow permissions correct
- [ ] First test release to TestPyPI successful
- [ ] First production release successful

---

## Quick Reference

### First Release:

```bash
# 1. Set up PyPI trusted publisher (one-time)
# 2. Run semantic-release
just release
# 3. Verify on PyPI after ~2-3 minutes
```

### Pre-release:

```bash
# Pre-releases go to TestPyPI automatically
# Use pre-release version format: v1.0.0-rc1
git tag v1.0.0-rc1
gh release create v1.0.0-rc1 --prerelease
```

### Manual Build & Test:

```bash
just build                           # Build locally
tar -tzf dist/*.tar.gz              # Check contents
just publish-test-manual            # Upload to TestPyPI
```

---

## Related Documentation

- **[RELEASE.md](RELEASE.md)** - Automated release workflow
- **[docs/SEMANTIC_RELEASE.md](docs/SEMANTIC_RELEASE.md)** - Complete semantic-release guide
- **[.github/workflows/publish.yml](.github/workflows/publish.yml)** - Publishing workflow
- **[PyPI Trusted Publishers Docs](https://docs.pypi.org/trusted-publishers/)**

---

**Last Updated:** 2025-10-14
