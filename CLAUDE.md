# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development with multi-provider hosting support. The add-on includes 22 custom commands, enhanced provider integration for Pantheon, WPEngine, and Kinsta, and complete tooling for modern WordPress development.

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
- `ddev db:refresh [env] [-f]`: Smart database refresh from hosting provider with backup age detection (12-hour threshold)
- `ddev db:rebuild`: Composer install followed by database refresh
- `ddev open`: Open project URL in browser

### Development Workflow Commands
- `ddev theme:install`: Set up Node.js, NPM, and build tools for theme development
- `ddev theme:npm <command>`: Run NPM commands in theme directory
- `ddev theme:npx <command>`: Run NPX commands in theme directory
- `ddev critical:install`: Install Critical CSS generation tools
- `ddev critical:run`: Run Critical CSS generation
- `ddev theme:watch`: Start theme development with file watching
- `ddev theme:build`: Build production theme assets

### Testing Commands
- `ddev cypress:install`: Install Cypress E2E testing dependencies
- `ddev cypress:run <command>`: Run Cypress commands with environment support
- `ddev cypress:users`: Create default admin user for Cypress testing
- `ddev pantheon:testenv <name> [type]`: Create isolated testing environment

### WordPress-Specific Commands
- `ddev theme:create-block <name>`: Create new WordPress block with template
- `ddev theme:activate`: Activate configured theme
- `ddev wp:restore-admin-user`: Create/restore admin user with configured credentials

### Migration and Database Commands
- `ddev db:prep-migrate`: Create secondary database for migrations
- `ddev pantheon:tickle`: Keep Pantheon environment awake (useful for long migrations)
- `ddev pantheon:terminus <command>`: Run Terminus commands for Pantheon integration

### Utility Commands
- `ddev phpmyadmin`: Launch PhpMyAdmin
- `ddev project:configure`: Interactive setup wizard for project configuration

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

The `ddev db:refresh` command includes intelligent backup management:
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
- **WordPress-specific**: Block creation (`theme:create-block`), admin user management (`wp:restore-admin-user`), multi-provider hosting support
- **Drupal-specific**: Recipe commands (`recipe:apply`, `recipe:uuid-rm`)
- **Hosting providers**: WordPress supports Pantheon, WPEngine, and Kinsta; Drupal focuses primarily on Pantheon
- **File structures**: WordPress uses different directory conventions than Drupal

### Repository Locations
- **WordPress add-on**: https://github.com/kanopi/ddev-kanopi-wp
- **Drupal add-on**: https://github.com/kanopi/ddev-kanopi-drupal

## Testing Notes
- Always test changes to install.yaml thoroughly across all providers
- Test multi-provider scenarios to ensure compatibility
- Validate nginx proxy configuration for each hosting platform
- Run integration tests before major releases
- Tests pre-configure environment variables to avoid interactive prompts
- Test changes in both add-ons when making cross-repository updates

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.