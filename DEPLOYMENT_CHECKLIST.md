# Release Deployment Checklist

## Pre-Release Validation

### Code Quality
- [ ] All tests passing in CI/CD (GitHub Actions)
- [ ] Integration tests completed successfully (`./tests/test-install.sh`)
- [ ] No console errors or warnings during installation
- [ ] Manual testing completed on all supported hosting providers:
  - [ ] Pantheon (with and without mu-plugins)
  - [ ] WPEngine
  - [ ] Kinsta

### Documentation
- [ ] CHANGELOG.md updated with all changes
- [ ] README.md reflects current functionality
- [ ] CLAUDE.md updated with any new patterns or commands
- [ ] MkDocs documentation updated (if applicable)
- [ ] Version references updated in documentation

### Version Management
- [ ] Version number decided (following Semantic Versioning)
  - **PATCH**: Bug fixes, refactors, minor improvements (1.2.11 → 1.2.12)
  - **MINOR**: New features, backward-compatible changes (1.2.11 → 1.3.0)
  - **MAJOR**: Breaking changes, significant architecture changes (1.2.11 → 2.0.0)
- [ ] Version number updated in `install.yaml` (if versioned there)
- [ ] Git tag prepared with version number

## Release Process

### 1. Create Release Branch
```bash
git checkout -b release/1.2.12
git push -u origin release/1.2.12
```

### 2. Update Version References
- [ ] Update CHANGELOG.md:
  - [ ] Change `[Unreleased]` to `[1.2.12] - YYYY-MM-DD`
  - [ ] Add new `[Unreleased]` section at top
  - [ ] Update comparison links at bottom
- [ ] Commit version updates:
```bash
git add CHANGELOG.md
git commit -m "chore(release): prepare version 1.2.12"
```

### 3. Create Pull Request
- [ ] Create PR from `release/1.2.12` → `main`
- [ ] Use PR description from this checklist (see below)
- [ ] Request review from team members
- [ ] Ensure all CI checks pass

### 4. Merge and Tag
- [ ] Merge PR to `main`
- [ ] Create and push git tag:
```bash
git checkout main
git pull origin main
git tag -a 1.2.12 -m "Release version 1.2.12"
git push origin 1.2.12
```

### 5. Create GitHub Release
- [ ] Go to GitHub Releases page
- [ ] Click "Draft a new release"
- [ ] Select tag: `1.2.12`
- [ ] Release title: `Version 1.2.12`
- [ ] Copy CHANGELOG entry to release notes
- [ ] Publish release

## Post-Release Validation

### DDEV Add-on Registry
- [ ] Verify add-on appears in DDEV add-on registry (may take time)
- [ ] Test installation via `ddev add-on get kanopi/ddev-kanopi-wp`

### Testing
- [ ] Fresh installation test on new project:
```bash
ddev config --project-type=wordpress --docroot=web
ddev add-on get kanopi/ddev-kanopi-wp
ddev project-configure
ddev project-init
```
- [ ] Upgrade test on existing project with previous version
- [ ] Verify all 26+ commands work correctly
- [ ] Test hosting provider integrations:
  - [ ] `ddev db-refresh` on Pantheon
  - [ ] `ddev db-refresh` on WPEngine
  - [ ] `ddev db-refresh` on Kinsta

### Communication
- [ ] Announce release in relevant channels (Slack, email, etc.)
- [ ] Update any external documentation or tutorials
- [ ] Notify dependent projects (if applicable)

## Rollback Plan

If critical issues are discovered post-release:

### Option 1: Hotfix Release
```bash
git checkout -b hotfix/1.2.13
# Fix the issue
git commit -m "fix: address critical issue from 1.2.12"
# Follow release process for 1.2.13
```

### Option 2: Revert to Previous Version
- [ ] Create GitHub release note warning about issues
- [ ] Document rollback instructions for users
- [ ] Point users to previous stable version (1.2.11)

## DDEV Add-on Specific Considerations

### Installation Testing
- [ ] Test `post_install_actions` complete successfully
- [ ] Verify `removal_actions` clean up properly
- [ ] Check that environment variables are set correctly
- [ ] Confirm nginx configuration is applied

### Command Testing
- [ ] All host commands execute without errors
- [ ] All web commands execute inside container correctly
- [ ] Configuration wizard (`ddev project-configure`) works end-to-end
- [ ] Initialization command (`ddev project-init`) completes full setup

### Multi-Provider Testing
- [ ] Pantheon: Terminus integration, multidev support, backup detection
- [ ] WPEngine: SSH key authentication, nightly backup retrieval
- [ ] Kinsta: SSH connection, database synchronization

### WordPress-Specific Testing
- [ ] wp-config.php modifications work correctly
- [ ] Admin user creation/restoration functions properly
- [ ] Theme development commands work with asset compilation
- [ ] Block creation scaffolding generates valid code
- [ ] Proxy configuration serves missing uploads

## Notes

- This is a DDEV add-on, not a WordPress plugin or theme
- Focus deployment validation on add-on installation and command functionality
- Test across different DDEV versions (minimum: v1.22.0)
- Ensure compatibility with multiple PHP versions (7.4, 8.0, 8.1, 8.2)
- Validate with different WordPress versions and hosting provider configurations
