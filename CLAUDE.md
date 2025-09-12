# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development with multi-provider hosting support. The add-on includes 20+ custom commands, enhanced provider integration for Pantheon, WPEngine, and Kinsta, and complete tooling for modern WordPress development.

## Architecture

### Command Structure
Commands are organized into two categories:
- **Host commands** (`commands/host/`): Execute on the host system outside containers
- **Web commands** (`commands/web/`): Execute inside the DDEV web container

### Core Components
- `install.yaml`: Add-on installation configuration and post-install actions
- `commands/`: Custom DDEV commands for development workflow
- `config/`: Enhanced provider configurations and development tools

## Common Development Commands

### Essential Commands
- `ddev init`: Complete project initialization with dependencies, Lefthook, NVM, Cypress, and database refresh
- `ddev refresh [env] [-f]`: Smart database refresh from hosting provider with backup age detection (12-hour threshold)
- `ddev rebuild`: Composer install followed by database refresh
- `ddev open`: Open project URL in browser

### Development Workflow Commands
- `ddev install-theme-tools`: Set up Node.js, NPM, and build tools for theme development
- `ddev npm <command>`: Run NPM commands in theme directory
- `ddev npx <command>`: Run NPX commands in theme directory
- `ddev install-critical-tools`: Install Critical CSS generation tools
- `ddev development`: Start theme development with file watching
- `ddev production`: Build production theme assets

### Testing Commands
- `ddev install-cypress`: Install Cypress E2E testing dependencies
- `ddev cypress <command>`: Run Cypress commands with environment support
- `ddev cypress-users`: Create default admin user for Cypress testing
- `ddev testenv <name> [install_type]`: Create isolated testing environment

### WordPress-Specific Commands
- `ddev create-block <name>`: Create new WordPress block with template
- `ddev activate-theme`: Activate configured theme
- `ddev restore-admin-user`: Create/restore admin user with configured credentials

### Migration and Database Commands
- `ddev migrate-prep-db`: Create secondary database for migrations
- `ddev tickle [site.env]`: Keep hosting environment awake (useful for long migrations)

### Utility Commands
- `ddev phpmyadmin`: Launch PhpMyAdmin
- `ddev configure`: Interactive setup wizard for project configuration

## Hosting Provider Support

### Pantheon
- **Docroot**: `web`
- **Environments**: dev, test, live, multidev
- **Authentication**: Terminus machine token
- **Database**: Automated backup management with age detection

### WPEngine
- **Docroot**: `wp`
- **Environments**: development, staging, production
- **Authentication**: API username and password
- **Database**: API-based backup retrieval

### Kinsta
- **Docroot**: `public`
- **Environments**: staging, live
- **Authentication**: API key
- **Database**: API-based backup management

## Configuration System

### Environment Variables (Legacy)
Key environment variables configured in `.ddev/.env.web`:
- `HOSTING_PROVIDER`: Platform identifier (pantheon, wpengine, kinsta)
- `HOSTING_SITE`: Site identifier on hosting platform
- `HOSTING_ENV`: Default environment for database pulls
- `THEME`: Path to custom theme directory (e.g., `wp-content/themes/custom/themename`)
- `THEMENAME`: Theme name for development tools

### YAML Configuration (Recommended)
Primary configuration in `.ddev/config.kanopi.yaml`:
```yaml
hosting:
  provider: pantheon|wpengine|kinsta
  
pantheon:
  site: your-site-name
  env: dev

wpengine:
  install: your-install-name
  env: development

kinsta:
  site: your-site-name
  env: staging

theme:
  relative_path: wp-content/themes/custom/themename
  slug: themename

wordpress:
  admin_user: admin
  admin_password: admin
  admin_email: admin@example.com

migration:
  source_site: source-site-name
  source_env: live
```

## Smart Refresh System

The `ddev refresh` command includes intelligent backup management:
- **Pantheon**: Automatically detects backup age (12-hour threshold)
- **WPEngine**: Uses API for backup retrieval and management
- **Kinsta**: Leverages API for database synchronization
- Uses `-f` flag to force new backup creation
- Supports any provider environment
- Includes automatic theme activation and admin user restoration after refresh

## Command Development Guidelines

### Host Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"
## OSTypes: darwin,linux,windows

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

# Load configuration from YAML
CONFIG_FILE="/var/www/html/.ddev/config.kanopi.yaml"
if [ -f "$CONFIG_FILE" ]; then
    # Use yq to parse YAML configuration
    SETTING=$(yq eval '.path.to.setting // "default"' "$CONFIG_FILE" 2>/dev/null || echo "default")
fi

# Command logic here
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

#### Global Configuration
1. **Pantheon**: Configure Terminus machine token globally:
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ```

2. **WPEngine**: Configure API credentials globally:
   ```bash
   ddev config global --web-environment-add=WPE_API_USERNAME=your_username
   ddev config global --web-environment-add=WPE_API_PASSWORD=your_password
   ```

3. **Kinsta**: Configure API key globally:
   ```bash
   ddev config global --web-environment-add=KINSTA_API_KEY=your_api_key
   ```

#### Project Setup
The add-on installation includes interactive prompts for:
- **HOSTING_PROVIDER**: Platform selection (pantheon/wpengine/kinsta)
- **THEME**: Path to active WordPress theme (e.g., `wp-content/themes/custom/mytheme`)
- **THEMENAME**: Theme name for development tools
- **HOSTING_SITE**: Platform-specific site identifier
- **HOSTING_ENV**: Default environment for database pulls
- **Migration settings**: Optional source site configuration

Alternatively, run `ddev configure` after installation for interactive setup.

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
- **Template-based block creation**: `ddev create-block <name>`
- **Modern WordPress development patterns**
- **React/JSX support for blocks**
- **SCSS compilation for block styles**

### Theme Development
- **Automated asset compilation**: `ddev production`
- **Development watching**: `ddev development`
- **Critical CSS generation**: Enhanced tooling for performance
- **Multi-environment asset management**

### Content Management
- **Admin user management**: Automated setup and restoration
- **Database synchronization**: Multi-provider support
- **Search/replace automation**: Domain updating for local development
- **Plugin management**: Automated deactivation of problematic plugins

## Testing Notes
- Always test changes to install.yaml thoroughly across all providers
- Test multi-provider scenarios to ensure compatibility
- Validate nginx proxy configuration for each hosting platform
- Run integration tests before major releases
- Tests pre-configure environment variables to avoid interactive prompts

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.