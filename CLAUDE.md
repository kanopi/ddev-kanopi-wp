# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development with multi-provider hosting support. The add-on includes 26 custom commands, enhanced provider integration for Pantheon, WPEngine, and Kinsta, and complete tooling for modern WordPress development.

## Architecture

### Command Structure
Commands are organized into two categories:
- **Host commands** (`commands/host/`): Execute on the host system outside containers
- **Web commands** (`commands/web/`): Execute inside the DDEV web container

The add-on uses a **modular command approach** where `project-init` orchestrates multiple smaller, focused commands:
- `project-auth`: Handle SSH key authorization for hosting providers
- `project-lefthook`: Install and initialize Lefthook git hooks
- `project-wp`: Install WordPress core and database if needed
- `project-configure`: Interactive configuration wizard

### Core Components
- `install.yaml`: Add-on installation configuration and post-install actions
- `commands/`: Custom DDEV commands for development workflow
- `config/`: Enhanced provider configurations and development tools

## Common Development Commands

### Essential Commands
- `ddev project-init`: Complete project initialization with dependencies, Lefthook, NVM, and database refresh
- `ddev project-auth`: Authorize SSH keys for hosting providers (called by project-init)
- `ddev project-lefthook`: Install and initialize Lefthook git hooks (called by project-init)
- `ddev project-wp`: Install WordPress core and database if needed (called by project-init)
- `ddev project-configure`: Interactive setup wizard for project configuration
- `ddev db-refresh [env] [-f]`: Smart database refresh from hosting provider with backup age detection (12-hour threshold)
- `ddev db-rebuild`: Composer install followed by database refresh
- `ddev wp-open`: Open project URL in browser

### Development Workflow Commands
- `ddev theme-install`: Set up Node.js, NPM, and build tools for theme development
- `ddev theme-npm <command>`: Run NPM commands in theme directory
- `ddev theme-npx <command>`: Run NPX commands in theme directory
- `ddev critical-install`: Install Critical CSS generation tools
- `ddev critical-run`: Run Critical CSS generation
- `ddev theme-watch`: Start theme development with file watching
- `ddev theme-build`: Build production theme assets

### Testing Commands
- `ddev cypress-install`: Install Cypress E2E testing dependencies
- `ddev cypress-run <command>`: Run Cypress commands with environment support
- `ddev cypress-users`: Create default admin user for Cypress testing
- `ddev pantheon-testenv <name> [type]`: Create isolated testing environment

### WordPress-Specific Commands
- `ddev theme-create-block <name>`: Create new WordPress block with template
- `ddev theme-activate`: Activate configured theme
- `ddev wp-restore-admin-user`: Create/restore admin user with configured credentials (automatically called after `ddev db-refresh`)
- `ddev wp-open [service]`: Open site or admin in browser (simplified using ddev launch)

### Migration and Database Commands
- `ddev db-prep-migrate`: Create secondary database for migrations
- `ddev pantheon-tickle`: Keep Pantheon environment awake (useful for long migrations)
- `ddev pantheon-terminus <command>`: Run Terminus commands for Pantheon integration

### Utility Commands
- Standard DDEV utilities available (`ddev describe`, `ddev logs`, etc.)

## Hosting Provider Support

### Pantheon
- **Recommended Docroot**: `web` (recommended for modern sites) or root/empty (legacy sites)
- **Environments**: dev, test, live, multidev
- **Authentication**: Terminus machine token
- **Database**: Automated backup management with age detection
- **Note**: Root-level WordPress (no webroot subdirectory) is fully supported for older Pantheon sites

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

## Configuration System

The add-on uses a simplified configuration approach with provider-specific variables managed through `ddev project-configure`.

### Configuration Storage
Variables are stored in multiple locations:
- **`.ddev/config.yaml`** (web_environment section): For DDEV containers to access via `printenv`
- **`.ddev/scripts/load-config.sh`**: For command scripts to source directly
- **`.ddev/config.local.yaml`** (optional): For user-specific variables like SSH keys (git-ignored)

### Common Variables (All Providers)
- `HOSTING_PROVIDER`: Platform identifier (pantheon, wpengine, kinsta)
- `THEME`: Path to custom theme directory (e.g., `wp-content/themes/custom/themename`)
- `THEMENAME`: Theme name for development tools
- `WP_ADMIN_USER`: WordPress admin username
- `WP_ADMIN_PASS`: WordPress admin password
- `WP_ADMIN_EMAIL`: WordPress admin email
- `WP_PREFIX`: WordPress database table prefix (default: `wp_`)
- `PROXY_URL`: Proxy URL for missing uploads/assets (automatically configured based on hosting provider)

### Provider-Specific Variables

#### Pantheon Configuration
- `HOSTING_SITE`: Pantheon site machine name
- `HOSTING_ENV`: Default environment for database pulls (dev/test/live)
- `DOCROOT`: Document root directory (`web` for modern sites, empty string for root-level WordPress on legacy sites)
- `MIGRATE_DB_SOURCE`: Source site for migrations (optional)
- `MIGRATE_DB_ENV`: Source environment for migrations (optional)

#### WPEngine Configuration
- `HOSTING_SITE`: WPEngine install name
- `WPENGINE_SSH_KEY`: Path to SSH private key for WPEngine access (stored in `.ddev/config.local.yaml` for user privacy)

#### Kinsta Configuration
- `REMOTE_HOST`: SSH host (IP address or hostname)
- `REMOTE_PORT`: SSH port number
- `REMOTE_USER`: SSH username
- `REMOTE_PATH`: Remote path on server (e.g., `/www/somepath/public`)
- `KINSTA_USERNAME`: Kinsta account username (e.g., `outandequalorg`)
- `HOSTING_ENV`: Environment name (e.g., `build`, `staging`, `live`)

### Configuration Command
Use `ddev project-configure` to set up all variables through an interactive wizard that collects only the variables needed for your chosen hosting provider.

### Local Configuration System
The add-on supports user-specific configuration through `.ddev/config.local.yaml` to keep personal settings separate from project-wide configuration:

#### Local Configuration File (`.ddev/config.local.yaml`)
- **Purpose**: Stores user-specific variables like SSH key paths
- **Git Status**: Automatically ignored to keep personal settings private
- **Format**: Standard DDEV configuration format with `web_environment` section
- **Usage**: Created automatically by `ddev project-configure` for WPEngine projects

#### Example Local Configuration
```yaml
#ddev-generated
# Local configuration for user-specific settings
# This file is ignored by git to keep personal settings private

web_environment:
  - WPENGINE_SSH_KEY=/Users/username/.ssh/wpengine_key
```

#### Template File
A template is provided at `config/config.local.example.yaml` showing the expected format for local configuration.

## Smart Refresh System

The `ddev db-refresh` command includes intelligent backup management:
- **Pantheon**: Automatically detects backup age (12-hour threshold) using Terminus API
- **WPEngine**: Uses SSH for backup retrieval and management
- **Kinsta**: Uses SSH for database synchronization
- Uses `-f` flag to force new backup creation
- Supports any provider environment
- Includes automatic theme activation and admin user restoration after refresh
- Automatically restores WordPress admin user credentials after database import

## Asset Proxy System

The add-on includes an intelligent nginx-based asset proxy system that automatically serves missing uploads and files from your hosting provider:

### How It Works:
- **Local First**: Always tries to serve files locally from `wp-content/uploads/`
- **Nginx Proxy**: If file doesn't exist locally, nginx directly proxies from remote hosting provider using `proxy_pass`
- **Provider Support**: Works with Pantheon, WPEngine, and Kinsta
- **Transparent**: No configuration needed - works automatically after setup

### Technical Implementation:
- **Complete nginx Configuration**: Uses `nginx-site-main.conf` template to override DDEV's default WordPress configuration
- **Template-Based**: `PROXY_URL_PLACEHOLDER` and `HOST_PLACEHOLDER` are replaced during `ddev project-configure`
- **Native nginx Performance**: Uses nginx's built-in `proxy_pass` directive for optimal performance
- **Configuration Location**: Creates `.ddev/nginx_full/nginx-site.conf` to take full control of nginx configuration

### Configuration:
- **Automatic**: `PROXY_URL` is automatically configured based on your hosting provider during `ddev project-configure`
- **Pantheon**: `https://dev-sitename.pantheonsite.io` (uses configured environment)
- **WPEngine**: `https://sitename.wpengine.com` (uses install name)
- **Kinsta**: `https://env-username-environment.kinsta.cloud` (e.g., `https://env-outandequalorg-build.kinsta.cloud`)

### Benefits:
- ✅ **Native nginx Performance**: Direct proxy without PHP processing overhead
- ✅ **Faster Development**: No need to download all uploads from production
- ✅ **Automatic Updates**: New uploads appear automatically without syncing
- ✅ **Bandwidth Efficient**: Only downloads files when actually needed
- ✅ **Cross-Platform**: Works with all supported hosting providers

## Command Development Guidelines

### Host Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e
# Command logic here
```

### Web Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Command logic here
# Variables like $HOSTING_PROVIDER, $THEME, etc. are now available
```

## Installation and Testing

### Local Development
```bash
# Test add-on installation
ddev add-on get /path/to/ddev-kanopi-wp

# Test removal
ddev add-on remove kanopi-wp
```

### Testing Framework
The project includes comprehensive testing:

#### Official DDEV Testing (CI)
Uses `ddev/github-action-add-on-test@v2` for standardized add-on validation in GitHub Actions.

#### Integration Testing (End-to-End)
```bash
# Run comprehensive integration test
./tests/test-install.sh
```

### Required Setup

#### Global Authentication Setup
1. **Pantheon**: Configure Terminus machine token globally:
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ```

2. **WPEngine**: Set up SSH key authentication:
   ```bash
   # Add your SSH public key to WPEngine User Portal
   # Then start SSH agent in DDEV
   ddev auth ssh
   ```

3. **Kinsta**: Set up SSH key authentication:
   ```bash
   # Add your SSH public key in MyKinsta > User Settings > SSH Keys
   # Then start SSH agent in DDEV
   ddev auth ssh
   ```

#### Project Setup
After installation, run the configuration wizard:
```bash
ddev project-configure
```

This wizard collects provider-specific variables:
- **All Providers**: WordPress admin credentials, theme configuration
- **Pantheon**: Site machine name, environment, migration settings (optional)
- **WPEngine**: Install name only
- **Kinsta**: SSH connection details (host, port, user, path)

## Dependencies

The add-on automatically installs and configures:
- **Lefthook** for git hooks
- **NVM** for Node.js version management
- **Cypress** for E2E testing
- **Terminus** for Pantheon API access (when using Pantheon)
- **Theme development tools** (Node.js, NPM)
- **Critical CSS generation tools**
- **Redis add-on** for caching
- **Multi-provider API tools** for hosting platform integration

## WordPress-Specific Features

### Block Development
- **Template-based block creation**: `ddev theme-create-block <name>`
- **Modern WordPress development patterns**
- **React/JSX support for blocks**
- **SCSS compilation for block styles**

### Theme Development
- **Automated asset compilation**: `ddev theme-build`
- **Development watching**: `ddev theme-watch`
- **Critical CSS generation**: Enhanced tooling for performance
- **Multi-environment asset management**

### Content Management
- **Admin user management**: Automated setup and restoration
- **Database synchronization**: Multi-provider support
- **Search/replace automation**: Domain updating for local development
- **Plugin management**: Automated deactivation of problematic plugins

## Cross-Repository Development

**IMPORTANT**: When working on this WordPress add-on, you should also work on the companion Drupal add-on (`ddev-kanopi-drupal`) to maintain consistency between both projects.

### Maintaining Feature Parity
Both add-ons should maintain feature parity where applicable:
- **Shared commands**: Database, theme, testing, and utility commands should have identical functionality
- **Configuration patterns**: Environment variables, file structures, and naming conventions should align
- **Documentation**: README files, command help text, and examples should be consistent
- **CI/CD**: Both projects should have identical GitHub Actions and CircleCI configurations

### Development Workflow
When making changes to this repository:
1. **Assess applicability**: Determine if the change should also be applied to the Drupal add-on
2. **Mirror changes**: If applicable, make equivalent changes in both repositories
3. **Test both**: Ensure changes work correctly in both WordPress and Drupal contexts
4. **Update documentation**: Keep README and CLAUDE.md files synchronized
5. **Maintain aliases**: Preserve backward compatibility in both add-ons

### Platform-Specific Differences
While maintaining consistency, respect platform differences:
- **WordPress-specific**: Block creation (`theme-create-block`), admin user management (`wp:restore-admin-user`), multi-provider hosting support
- **Drupal-specific**: Recipe commands (`recipe-apply`, `recipe-uuid-rm`)
- **Hosting providers**: WordPress supports Pantheon, WPEngine, and Kinsta; Drupal focuses primarily on Pantheon
- **File structures**: WordPress uses different directory conventions than Drupal

### Repository Locations
- **WordPress add-on**: https://github.com/kanopi/ddev-kanopi-wp
- **Drupal add-on**: https://github.com/kanopi/ddev-kanopi-drupal

## Testing Notes
- Always test changes to install.yaml thoroughly across all providers
- Test multi-provider scenarios to ensure compatibility
- Validate nginx proxy configuration for each hosting platform:
  - Test that `nginx-site-main.conf` template properly replaces placeholders
  - Verify proxy functionality with missing uploads from each provider
  - Confirm that complete nginx configuration overrides DDEV's default
- Run integration tests before major releases
- Tests pre-configure environment variables to avoid interactive prompts
- Test changes in both add-ons when making cross-repository updates

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
