# Deployment Checklist - Version 1.2.13

**Target Environment**: Production
**Release Date**: 2026-01-13
**Release Type**: Minor Version (Feature Addition)

## Pre-Deployment

### Version Control
- [ ] All tests pass in CI/CD pipeline
- [ ] Version number updated to 1.2.13 in relevant files
- [ ] CHANGELOG.md updated with release notes
- [ ] README.md updated if needed (Remote SSH provider documentation)
- [ ] All commits follow conventional commit format
- [ ] No sensitive data (credentials, API keys) in commit history

### WordPress-Specific Checks
- [ ] Verify Remote SSH hosting provider integration works with WP-CLI
- [ ] Test database refresh with Remote SSH provider (`ddev db-refresh`)
- [ ] Test project configuration wizard with Remote SSH option (`ddev project-configure`)
- [ ] Verify SSH key authentication for remote hosts
- [ ] Test search/replace with `REMOTE_DOMAIN` configuration
- [ ] Verify proxy URL configuration for Remote SSH providers
- [ ] Test docroot path resolution in remote scripts
- [ ] Verify post-refresh admin user restoration works

### Cross-Provider Compatibility
- [ ] Test existing Pantheon functionality unchanged
- [ ] Test existing WPEngine functionality unchanged
- [ ] Test existing Kinsta functionality unchanged
- [ ] Verify backward compatibility with existing configurations

### Documentation
- [ ] Update README.md with Remote SSH provider section
- [ ] Update CLAUDE.md with Remote SSH configuration details
- [ ] Verify all command help text is accurate
- [ ] Update provider comparison table if needed

## Testing Scenarios

### 1. Fresh Installation with Remote SSH
```bash
ddev add-on get kanopi/ddev-kanopi-wp
ddev project-configure  # Select "remote"
ddev project-init
```
- [ ] Remote SSH provider selection works
- [ ] Configuration wizard collects all required fields
- [ ] Project initialization completes successfully

### 2. Database Refresh Testing
```bash
# Test with cached backup (< 12 hours)
ddev db-refresh

# Test force refresh
ddev db-refresh -f

# Verify database
ddev wp db check --allow-root
```
- [ ] Cached backup detection works (12-hour threshold)
- [ ] Force refresh creates fresh backup
- [ ] Database imports successfully
- [ ] Admin user restoration works

### 3. SSH Connectivity Validation
```bash
# Test with invalid configuration
# (Modify REMOTE_HOST in .ddev/config.yaml to invalid value)
ddev restart
ddev db-refresh
```
- [ ] Clear error messages displayed
- [ ] Troubleshooting guidance provided
- [ ] Graceful failure handling

### 4. Configuration Persistence
```bash
ddev exec printenv | grep REMOTE
cat .ddev/config.yaml | grep -A 10 "web_environment"
cat .ddev/scripts/load-config.sh | grep -A 10 "remote"
```
- [ ] REMOTE_* variables saved correctly
- [ ] Configuration persists across restarts
- [ ] load-config.sh includes Remote SSH section

### 5. Backward Compatibility
```bash
# Test existing Pantheon project
ddev project-configure  # Select "pantheon"
ddev db-refresh dev

# Test existing WPEngine project
ddev project-configure  # Select "wpengine"
ddev db-refresh

# Test existing Kinsta project
ddev project-configure  # Select "kinsta"
ddev db-refresh
```
- [ ] Pantheon functionality unchanged
- [ ] WPEngine functionality unchanged
- [ ] Kinsta functionality unchanged

## Release Process

### GitHub Release
- [ ] Create release branch: `release/1.2.13` (if using release branches)
- [ ] Update version references in documentation
- [ ] Create GitHub release with changelog
- [ ] Tag release: `1.2.13`
- [ ] Merge to main branch (if using release branches)
- [ ] Verify GitHub releases page updated
- [ ] Verify add-on installation from GitHub works

### Installation Verification
```bash
# Test fresh installation
ddev add-on get kanopi/ddev-kanopi-wp

# Test version-specific installation
ddev add-on get kanopi/ddev-kanopi-wp --version=1.2.13
```
- [ ] Fresh installation works from GitHub
- [ ] Version-specific installation works
- [ ] All commands available after installation

## Post-Release

### Monitoring
- [ ] Monitor GitHub issues for bug reports
- [ ] Watch for Remote SSH-related feedback
- [ ] Check CI/CD pipeline for failures
- [ ] Review user-reported issues

### Documentation Updates
- [ ] Update companion Drupal add-on with equivalent features (if applicable)
- [ ] Announce release in team channels
- [ ] Update project documentation site (if exists)
- [ ] Create tutorial/blog post for Remote SSH configuration

### Follow-up Tasks
- [ ] Update ddev-kanopi-drupal with Remote SSH support
- [ ] Create example configurations for common remote hosts
- [ ] Add Remote SSH provider to feature comparison documentation
- [ ] Consider additional provider-specific optimizations

## Rollback Plan

### If Issues Occur
- [ ] Previous version (1.2.12) tagged and available
- [ ] Rollback command: `ddev add-on get kanopi/ddev-kanopi-wp --version=1.2.12`
- [ ] No database schema changes (rollback safe)
- [ ] Configuration variables backward compatible

### Rollback Steps
```bash
# Remove current version
ddev add-on remove kanopi-wp

# Install previous version
ddev add-on get kanopi/ddev-kanopi-wp --version=1.2.12

# Restart DDEV
ddev restart
```

### Rollback Verification
- [ ] Previous version installs successfully
- [ ] Existing projects continue working
- [ ] No data loss or configuration corruption
- [ ] All existing commands functional

## Notes

### Breaking Changes
**None** - This release adds new functionality without modifying existing provider behavior.

### Migration Notes
- Existing Pantheon, WPEngine, and Kinsta configurations are unchanged
- No action required for existing users
- Remote SSH is an opt-in provider for new configurations

### Configuration Requirements for Remote SSH
- SSH key authentication configured on remote host
- Remote host has WP-CLI installed and accessible
- SSH agent running in DDEV: `ddev auth ssh`
- Required environment variables:
  - `REMOTE_HOST`: SSH hostname or IP
  - `REMOTE_PORT`: SSH port (typically 22)
  - `REMOTE_USER`: SSH username
  - `REMOTE_PATH`: Absolute path to WordPress installation
  - `REMOTE_DOMAIN`: Domain for search/replace operations

### Known Limitations
- Remote SSH provider requires WP-CLI on remote host
- No support for MySQL dump file backups (WP-CLI only)
- Backup age detection requires consistent remote server time

---

**Deployment Completed**: ___________
**Verified By**: ___________
**Sign-off**: ___________
