# Pantheon Integration

Full integration with Pantheon hosting including Terminus CLI, automated backup management, and multidev environment support.

## Configuration

### Required Variables
- `HOSTING_SITE` - Pantheon site machine name
- `HOSTING_ENV` - Default environment for database pulls (dev/test/live)
- `DOCROOT` - Document root directory (`web` recommended for modern sites, empty for root-level WordPress on legacy sites)
- `MIGRATE_DB_SOURCE` - Source project for migrations (optional)
- `MIGRATE_DB_ENV` - Source environment for migrations (optional)

### Setup Process

1. **Get Machine Token**
   Visit [Pantheon Dashboard](https://dashboard.pantheon.io/machine-token/create) to create a machine token.

2. **Configure Global Authentication**
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ddev restart
   ```

3. **Project Configuration**
   ```bash
   ddev project-configure
   # Select Pantheon as provider
   # Enter site machine name
   # Choose default environment
   # Configure document root (web or leave empty for root)
   ```

## WordPress Installation Location

Pantheon sites can have WordPress installed in different locations:

### Modern Sites (Recommended)
- **Document root**: `web/`
- **WordPress core**: `/web/` directory
- **Configuration during setup**: Enter "web" when prompted for document root
- **Best for**: New projects, Composer-managed WordPress, clean directory structure

### Legacy Sites (Alternative)
- **Document root**: Root/application root
- **WordPress core**: Root directory (no subdirectory)
- **Configuration during setup**: Leave document root empty or press Enter when prompted
- **Best for**: Older Pantheon sites, sites migrated from other hosts

### Configuration Examples

**Modern site with web/ subdirectory:**
```bash
ddev project-configure
# When prompted: "Document root directory (web for modern sites, or leave empty for root/legacy sites) [web]:"
# Enter: web (or press Enter to accept default)
```

**Legacy site with root-level WordPress:**
```bash
ddev project-configure
# When prompted: "Document root directory (web for modern sites, or leave empty for root/legacy sites) [web]:"
# Enter: (press Enter without typing anything, or explicitly type empty string)
```

### Troubleshooting 404 Errors

If you experience 404 errors after setup, verify your document root configuration:

1. **Check your Pantheon site structure**:
   - Does `wp-config.php` exist in the root directory or in a `web/` subdirectory?
   - Where are `wp-content/`, `wp-includes/`, and `wp-admin/` located?

2. **Verify DDEV configuration**:
   ```bash
   grep '^docroot:' .ddev/config.yaml
   # Should show: docroot: web (for modern sites)
   # Or: docroot: "" (for root-level WordPress)
   ```

3. **Re-run configuration if needed**:
   ```bash
   ddev project-configure
   # Provide the correct document root
   ddev restart
   ```

### Migrating Between Configurations

**Existing projects** with `web/` subdirectory continue working without changes. To explicitly update configuration:

```bash
ddev project-configure
# Re-enter your settings with correct document root
ddev restart
```

## Features

### Smart Database Refresh
- **12-hour backup detection**: Automatically checks backup age using Terminus API
- **Environment support**: Works with dev, test, live, and multidev environments
- **Force refresh**: Use `-f` flag to create new backups

```bash
# Refresh from default environment
ddev db-refresh

# Refresh from live with force flag
ddev db-refresh live -f

# Refresh from multidev environment
ddev db-refresh feature-branch
```

### Terminus Integration
Run any Terminus command through DDEV:

```bash
# List all sites
ddev pantheon-terminus site:list

# Check environment info
ddev pantheon-terminus env:info my-site.dev

# Create multidev environment
ddev pantheon-terminus multidev:create my-site.live feature-branch
```

### Test Environment Management
Create isolated testing environments:

```bash
# Create fresh test environment
ddev pantheon-testenv my-test fresh

# Create from existing environment
ddev pantheon-testenv my-test existing
```

### Environment Tickling
Keep environments awake during long operations:

```bash
# Start tickling to prevent sleep
ddev pantheon-tickle
```

## Authentication Troubleshooting

### Check Token Status
```bash
# Verify token is set
ddev exec printenv TERMINUS_MACHINE_TOKEN

# Test authentication
ddev pantheon-terminus auth:whoami
```

### Re-authenticate
```bash
# Re-authenticate manually
ddev pantheon-terminus auth:login --machine-token="your_token"
```

## File Proxy Configuration

The add-on automatically configures file proxy to serve missing uploads from your live environment:

- Seamless local development experience
- No need to download all production files
- Configurable proxy settings per environment

## Multidev Support

Full support for Pantheon's multidev environments:

- Database refresh from any multidev
- Environment creation and management
- Seamless switching between environments

```bash
# Work with multidev environments
ddev db-refresh my-feature-branch
ddev pantheon-terminus multidev:list my-site
```

## Migration Support

Configure migration settings for database operations between different Pantheon sites:

```bash
# During configuration, optionally set:
# MIGRATE_DB_SOURCE - Source site machine name
# MIGRATE_DB_ENV - Source environment (dev/test/live)
```

This enables database operations between different Pantheon projects for complex migration workflows.