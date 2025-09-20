# Hosting Providers

The add-on supports all major WordPress hosting platforms with provider-specific optimizations and integrations.

## Supported Platforms

- **[Pantheon](providers/pantheon.md)**: Full Terminus integration with automated backup management
- **[WPEngine](providers/wpengine.md)**: SSH-based operations with specific key handling
- **[Kinsta](providers/kinsta.md)**: Direct SSH access with custom configurations

## Configuration Overview

Each provider requires specific configuration during the `ddev project-configure` setup:

### Common Variables (All Providers)
- `HOSTING_PROVIDER` - Platform identifier (pantheon, wpengine, kinsta)
- `THEME` - Path to custom theme directory (e.g., `wp-content/themes/custom/themename`)
- `THEMENAME` - Theme name for development tools
- `WP_ADMIN_USER` - WordPress admin username
- `WP_ADMIN_PASS` - WordPress admin password
- `WP_ADMIN_EMAIL` - WordPress admin email

## Provider-Specific Features

### Pantheon
- **Recommended Docroot**: `web` (set during `ddev config`)
- **Environments**: dev, test, live, multidev
- **Authentication**: Terminus machine token
- **Database**: Automated backup management with age detection

### WPEngine
- **Recommended Docroot**: `public` (set during `ddev config`)
- **Authentication**: Specific SSH key (WPEngine allows only one key per account)
- **Database**: SSH-based backup retrieval using nightly backups
- **Variables**: `HOSTING_SITE` (install name), `WPENGINE_SSH_KEY` (SSH key path)

### Kinsta
- **Recommended Docroot**: `public` (set during `ddev config`)
- **Authentication**: SSH keys
- **Database**: SSH-based backup retrieval
- **Variables**: `REMOTE_HOST`, `REMOTE_PORT`, `REMOTE_USER`, `REMOTE_PATH`

## Configuration Storage

Variables are stored in two locations:
- **`.ddev/config.yaml`** (web_environment section): For DDEV containers to access via `printenv`
- **`.ddev/scripts/load-config.sh`**: For command scripts to source directly

## Authentication Setup

### Global Setup Required

Each provider requires initial authentication setup:

#### Pantheon
```bash
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
```

#### WPEngine
```bash
# Add SSH public key to WPEngine User Portal
# Configure specific SSH key during project setup
```

#### Kinsta
```bash
# Add SSH public key in MyKinsta > User Settings > SSH Keys
ddev auth ssh
```

## Smart Database Refresh

The enhanced `ddev db-refresh` command works across all providers:

- **Automatic Backup Age Detection**: Checks if backups are older than 12 hours
- **Force Flag Support**: Use `-f` to create fresh backups regardless of age
- **Multi-Environment Support**: Works with dev, test, live, and multidev environments
- **Provider Agnostic**: Unified interface across all platforms

```bash
# Refresh from dev (default)
ddev db-refresh

# Refresh from live environment
ddev db-refresh live

# Force new backup creation
ddev db-refresh -f

# Refresh from specific environment
ddev db-refresh staging
```

## Platform-Specific Configurations

### Webserver Configuration
- **Nginx**: Custom configuration for WordPress optimization
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- **Gzip Compression**: Optimized for web assets
- **Static File Serving**: Efficient handling of CSS, JS, images

### File Proxy Configuration
- **Pantheon**: Proxy missing uploads from live environment
- **Multi-provider support**: Configurable proxy settings
- **Local development**: Seamless asset loading