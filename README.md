# DDEV Kanopi WordPress Add-on

[![tests](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/kanopi/ddev-kanopi-wp)](https://github.com/kanopi/ddev-kanopi-wp/commits)
[![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

A comprehensive DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development. This add-on includes complete tooling for modern WordPress development with multi-provider hosting support.

## Features

This add-on provides:

- **22 Custom Commands**: Complete WordPress development workflow with namespaced commands
- **Multi-Provider Hosting**: Support for Pantheon, WPEngine, and Kinsta hosting platforms
- **Block Creation Tooling**: Command to generate custom WordPress blocks with proper scaffolding
- **Asset Compilation**: Webpack-based build system using `@wordpress/scripts`
- **Testing Framework**: Cypress E2E testing with user management
- **Database Management**: Smart refresh system with 12-hour backup detection
- **Theme Development**: Node.js, NPM, and build tools with file watching
- **Security & Performance**: Nginx configuration with headers and optimization
- **Services Integration**: PHPMyAdmin, Redis, and Solr via official DDEV add-ons
- **Environment Configuration**: Clean configuration system using environment variables

## Installation

### For Existing DDEV Projects

```bash
# Install the add-on (includes interactive configuration)
ddev add-on get kanopi/ddev-kanopi-wp

# Restart DDEV to apply changes
ddev restart
```

### For Projects Without DDEV

#### Step 1: Install DDEV (if not already installed)

```bash
# Using Homebrew (recommended)
brew install ddev/ddev/ddev

# Install DDEV
curl -fsSL https://ddev.com/install.sh | bash

# Or using the installer script
# See: https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/
```

#### Step 2: Initialize DDEV in Your Project

```bash
# Stop conflicting development tools first
# Docksal users
fin system stop

# Lando users
lando destroy

# Navigate to your WordPress project
cd /path/to/your/wordpress/project

# Initialize DDEV configuration
ddev config --project-name=your-project-name --project-type=wordpress --docroot=web --create-docroot

# Configure wp-config.php (if you have an existing one)
# Add this snippet to your wp-config.php before the wp-settings.php line:
```

```php
// Include for ddev-managed settings in wp-config-ddev.php.
$ddev_settings = dirname(__FILE__) . '/wp-config-ddev.php';
if (is_readable($ddev_settings) && !defined('DB_USER')) {
  require_once($ddev_settings);
}
```

```bash
# Install the Kanopi WordPress add-on
ddev add-on get kanopi/ddev-kanopi-wp
```

#### Step 3: Spin up project

```bash
# Initialize
ddev init
```

## Interactive Installation

The add-on includes an interactive configuration wizard that prompts for:

1. **Hosting Provider**: Pantheon, WPEngine, or Kinsta
2. **WordPress Admin**: Username, password, and email
3. **Hosting Details**: Site-specific configuration (e.g., Pantheon site name)
4. **Theme Configuration**: Theme path and name
5. **Migration Settings**: Source project for database migrations (optional)

After installation, initialize your development environment:

```bash
# Configure your project settings (interactive wizard)
ddev project:configure

# Initialize your complete development environment
ddev init
```

**`ddev init`** performs the following automatically:
- Start DDEV
- Install Lefthook (git hooks) if configured
- Set up NVM for Node.js management
- Add SSH keys for remote access
- Install Composer dependencies
- Download WordPress core (if needed)
- Pull database from hosting provider (if configured)
- Install theme dependencies and build assets
- Activate theme and restore admin user
- Generate admin login link

## Available Commands

| Command | Type | Description | Example | Aliases |
|---------|------|-------------|---------|---------|
| `ddev critical:install` | Web | Install Critical CSS generation tools | `ddev critical:install` | install-critical-tools, cri, critical-install |
| `ddev critical:run` | Web | Run Critical CSS generation | `ddev critical:run` | critical, crr, critical-run |
| `ddev cypress:install` | Host | Install Cypress E2E testing dependencies | `ddev cypress:install` | cyi, cypress-install, install-cypress |
| `ddev cypress:run <command>` | Host | Run Cypress commands with environment support | `ddev cypress:run open` | cy, cypress, cypress-run, cyr |
| `ddev cypress:users` | Host | Create default admin user for Cypress testing | `ddev cypress:users` | cyu, cypress-users |
| `ddev db:prep-migrate` | Web | Create secondary database for migrations | `ddev db:prep-migrate` | migrate-prep-db, db-prep-migrate, db-mpdb |
| `ddev db:rebuild` | Host | Run composer install followed by database refresh | `ddev db:rebuild` | rebuild, db-rebuild, dbreb |
| `ddev db:refresh [env] [-f]` | Web | Smart database refresh with 12-hour backup age detection | `ddev db:refresh live -f` | refresh, db-refresh, dbref |
| `ddev init` | Host | **Initialize complete development environment** (runs all setup commands) | `ddev init` | - |
| `ddev open [service]` | Web | Open the site or admin in your default browser | `ddev open` or `ddev open cms` | - |
| `ddev pantheon:testenv <name> [type]` | Host | Create isolated testing environment (fresh or existing) | `ddev pantheon:testenv my-test fresh` | testenv, pantheon-testenv |
| `ddev pantheon:terminus <command>` | Host | Run Terminus commands for Pantheon integration | `ddev pantheon:terminus site:list` | terminus, pantheon-terminus |
| `ddev pantheon:tickle` | Web | Keep Pantheon environment awake during long operations | `ddev pantheon:tickle` | tickle, pantheon-tickle |
| `ddev phpmyadmin` | Host | Launch PhpMyAdmin database interface | `ddev phpmyadmin` | - |
| `ddev project:configure` | Host | **Interactive setup wizard** (configure project settings) | `ddev project:configure` | configure, project-configure, prc |
| `ddev theme:activate` | Web | Activate the custom theme | `ddev theme:activate` | activate-theme, tha, theme-activate |
| `ddev theme:build` | Web | Build production assets | `ddev theme:build` | production, theme-build, thb, theme-production |
| `ddev theme:create-block <block-name>` | Web | Create a new WordPress block with proper scaffolding | `ddev theme:create-block my-block` | create-block, thcb, theme-create-block |
| `ddev theme:install` | Web | Set up Node.js, NPM, and build tools using .nvmrc | `ddev theme:install` | install-theme-tools, thi, theme-install |
| `ddev theme:npm <command>` | Web | Run npm commands (automatically runs in theme directory if available) | `ddev theme:npm run build` | npm, theme-npm |
| `ddev theme:npx <command>` | Web | Run NPX commands in theme directory | `ddev theme:npx webpack --watch` | npx, theme-npx |
| `ddev theme:watch` | Web | Start the development server with file watching | `ddev theme:watch` | development, thw, theme-watch, theme-development |
| `ddev wp:restore-admin-user` | Web | Restore the admin user credentials | `ddev wp:restore-admin-user` | restore-admin-user, wp-restore-admin-user, wp-rau |

## Smart Database Refresh

The enhanced `ddev db:refresh` command includes intelligent backup management:

- **Automatic Backup Age Detection**: Checks if backups are older than 12 hours
- **Force Flag Support**: Use `-f` to create fresh backups regardless of age
- **Multi-Environment Support**: Works with dev, test, live, and multidev environments
- **Provider Agnostic**: Works across Pantheon, WPEngine, and Kinsta

```bash
# Refresh from dev (default)
ddev db:refresh

# Refresh from live environment
ddev db:refresh live

# Force new backup creation
ddev db:refresh -f

# Refresh from specific environment
ddev db:refresh staging
```

## Theme Development Workflow

### Set up Node.js and build tools
```bash
# Install Node.js, NPM, and build tools (one-time setup)
ddev theme:install

# Start theme development with file watching
ddev theme:watch

# Build production assets
ddev theme:build
```

### Block Development
```bash
# Create a new WordPress block
ddev theme:create-block my-custom-block

# Start development server
ddev theme:watch
```

Your block will be created in `web/wp-content/themes/[theme]/assets/src/blocks/my-custom-block/` with:
- `block.json` - Block metadata
- `index.js` - Block registration
- `edit.js` - Editor interface
- `save.js` - Frontend output (or `render.php` for server-side rendering)
- `style.scss` - Frontend styles
- `editor.scss` - Editor styles
- `view.js` - Frontend JavaScript

### Critical CSS Generation

```bash
# Install Critical CSS tools (one-time setup)
ddev critical:install

# Generate critical CSS for improved performance
ddev critical:run
```

## Search Integration

### Redis Integration
- Object caching automatically configured
- Session storage handled via Redis
- Compatible with hosting provider caching layers

### Solr Integration
- Full-text search capabilities via ddev/ddev-solr
- Compatible with Pantheon Solr and other hosting providers
- Configured for WordPress content indexing

## Environment Variables

Key environment variables configured in `.ddev/config.yaml`:

- `HOSTING_PROVIDER` - Your hosting platform (pantheon/wpengine/kinsta)
- `HOSTING_SITE` - Your site identifier (e.g., pantheon site name)
- `HOSTING_ENV` - Default environment for database pulls (dev/staging/live)
- `THEME` - Path to your custom theme
- `THEMENAME` - Theme name for development tools
- `WP_ADMIN_USER` - WordPress admin username
- `WP_ADMIN_PASS` - WordPress admin password
- `WP_ADMIN_EMAIL` - WordPress admin email
- `MIGRATE_DB_SOURCE` - Source project for migrations (optional)
- `MIGRATE_DB_ENV` - Source environment for migrations (optional)

## Managing This Add-on

### View Installed Add-ons
```bash
# List all installed add-ons
ddev add-on list
```

### Update the Add-on
```bash
# Update to the latest version
ddev add-on get kanopi/ddev-kanopi-wp
ddev restart
```

### Remove the Add-on
```bash
# Remove the add-on completely (includes Redis, Solr, and all 22 commands)
ddev add-on remove kanopi-wordpress

# Restart DDEV to apply changes
ddev restart
```

## Post-Installation Setup

### Required Configuration Steps

#### 1. Configure Hosting Provider Authentication

**For Pantheon:**
```bash
# Set the token globally for all DDEV projects
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
ddev restart
```

**For WPEngine:**
```bash
# Configure SSH access (add your SSH key to WPEngine account)
ddev auth ssh
```

**For Kinsta:**
```bash
# Set Kinsta API credentials globally for all DDEV projects
ddev config global --web-environment-add=KINSTA_API_KEY=your_api_key
ddev restart
```

#### 2. Stop Conflicting Development Tools

- **Docksal**: `fin system stop`
- **Lando**: `lando destroy`
- **Local by Flywheel**: Stop all sites
- **MAMP/XAMPP**: Stop services

#### 3. Configure wp-config.php for DDEV

Ensure your `wp-config.php` includes DDEV database settings:

```php
// Include for ddev-managed settings in wp-config-ddev.php.
$ddev_settings = dirname(__FILE__) . '/wp-config-ddev.php';
if (is_readable($ddev_settings) && !defined('DB_USER')) {
  require_once($ddev_settings);
}
```

#### 4. Review and Update Theme Tools Command

```bash
# Review the command
ddev theme:install --help

# Test the command in your theme directory
ddev theme:install
```

#### 5. Convert Existing Custom Commands

If you have custom DDEV commands, convert them to use the new namespace structure:

```bash
# View existing command structure
find .ddev/commands -name "*" -type f

# Copy a similar command as a template
cp .ddev/commands/web/theme:watch .ddev/commands/web/my-custom-command
```

#### 6. Update Project Documentation

Update your project's README and documentation to reference the new commands and workflow.

## Local Development with DDEV

### DDEV Setup

```bash
# Start DDEV and run initialization
ddev init

# This will:
# - Install Lefthook git hooks
# - Set up NVM for Node.js
# - Install Cypress for testing
# - Refresh database from hosting provider
# - Create Cypress test users
```

### Available DDEV Commands

#### 7. Initial Project Setup

```bash
# Start DDEV and run initialization
ddev init

# This will:
# - Install Lefthook git hooks
# - Set up NVM for Node.js
# - Install Cypress for testing
# - Refresh database from hosting provider
# - Create Cypress test users
```

### Verification Steps

1. **Test database refresh**: `ddev db:refresh`
2. **Test theme tools**: `ddev theme:install`
3. **Verify hosting connection**: `ddev pantheon:terminus site:list` (or appropriate provider command)
4. **Test development server**: Visit your local site and check if assets load properly

## Quick Reference

### Common Workflow
```bash
# Daily development workflow
ddev init

# or individually
ddev start                    # Start DDEV
ddev db:refresh               # Get latest database
ddev theme:install           # Set up theme tools (first time)
ddev theme:watch             # Start theme development

# Testing workflow
ddev cypress:install         # Set up Cypress (first time)
ddev cypress:users          # Create test users
ddev cypress:run open       # Open Cypress

# Deployment preparation
ddev theme:build            # Build production assets
```

### Key Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `HOSTING_PROVIDER` | Hosting platform | `pantheon`, `wpengine`, `kinsta` |
| `HOSTING_SITE` | Site identifier | `my-wp-site` |
| `HOSTING_ENV` | Default environment | `dev`, `test`, `live` |
| `THEME` | Theme path | `wp-content/themes/custom/mytheme` |
| `WP_ADMIN_USER` | Admin username | `admin` |

## Troubleshooting

### Pantheon Authentication Issues
```bash
# Check if token is set
ddev exec printenv TERMINUS_MACHINE_TOKEN

# Re-authenticate manually
ddev pantheon:terminus auth:login --machine-token="your_token"
```

### WPEngine Authentication Issues
```bash
# Check SSH access
ddev auth ssh

# Test connection
ssh your-install@your-install.ssh.wpengine.net
```

### Kinsta Authentication Issues
```bash
# Check if API credentials are set
ddev exec printenv KINSTA_API_KEY

# Test API access (if available)
# Kinsta CLI commands would go here
```

### Theme Build Issues
```bash
# Check Node.js version
ddev exec node --version

# Reinstall dependencies
ddev theme:install
```

### Database Refresh Issues

**For Pantheon:**
```bash
# Check Pantheon connection
ddev pantheon:terminus site:list

# Force new backup
ddev db:refresh -f
```

**For WPEngine:**
```bash
# Check SSH connection
ddev auth ssh

# Test database access
# WPEngine-specific debugging commands
```

**For Kinsta:**
```bash
# Check API connection and credentials
# Kinsta-specific debugging commands
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

## Testing

### 1. Automated CI/CD Testing
This add-on includes comprehensive automated testing via:
- **GitHub Actions**: Standard add-on testing with extended bats tests
- **CircleCI**: Machine-based testing with comprehensive validation

### 2. Local Development Testing

```bash
# Run comprehensive bats tests
bats tests/test.bats
```

### 3. Component Testing

```bash
# Install bats if not already installed
# macOS: brew install bats-core
# Linux: See https://bats-core.readthedocs.io/en/stable/installation.html

# Run component tests
bats --verbose-run tests/test.bats
```

### Testing Strategy

| Test Level | Purpose | When to Use |
|------------|---------|-------------|
| **GitHub Actions** | Automated validation | Every push/PR |
| **CircleCI** | Machine-based validation | Continuous integration |
| **Bats Tests** | Component functionality | Feature development |

### Debugging Failed Tests

```bash
# Navigate to test environment (if using test-install.sh)
cd tests/test-install/wordpress

# Check DDEV status
ddev describe

# Verify environment variables
ddev exec printenv | grep -E "(HOSTING|THEME|WP_)"

# Check installed add-ons
ddev add-on list

# Cleanup when done
ddev delete -Oy
```

## Contributing

Contributions are welcome! Please ensure:

- **Testing**: All commands are tested in the `tests/test.bats` file
- **Documentation**: Update documentation for new features
- **Code Style**: Follow existing conventions and patterns
- **Backwards Compatibility**: Maintain alias support for renamed commands

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests
5. Submit a pull request

## License

This project is licensed under the GNU General Public License v2 - see the [LICENSE](LICENSE) file for details.

---

**Originally Contributed by [Kanopi Studios](https://kanopi.com)**
