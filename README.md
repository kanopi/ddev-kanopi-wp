# ddev-kanopi-wp

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kanopi/ddev-kanopi-wp/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/kanopi/ddev-kanopi-wp/tree/main) ![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

## What is ddev-kanopi-wp?

This repository provides a DDEV add-on that configures a WordPress development environment with Kanopi's standard tooling and workflows. It includes:

- **Block Creation Tooling**: Command to generate custom WordPress blocks with proper scaffolding
- **Multi-Provider Hosting**: Support for Pantheon, WPEngine, and Kinsta hosting platforms
- **Development Workflow**: Asset compilation, code quality tools, and development server setup  
- **WordPress Configuration**: Pre-configured services using official DDEV add-ons (PHPMyAdmin, Redis, Solr)
- **Environment Variable Configuration**: Clean configuration system without YAML files

This add-on converts the existing Docksal-based Kanopi WordPress workflow to DDEV, providing the same functionality and commands in a DDEV environment.

## Installation

### New DDEV Project

```bash
ddev add-on get kanopi/ddev-kanopi-wp
```

### Existing Project Without DDEV

To add this addon to an existing WordPress project that doesn't have DDEV:

1. **Install DDEV** (if not already installed):
   ```bash
   # macOS with Homebrew
   brew install ddev/ddev/ddev
   
   # Other platforms: https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/
   ```

2. **Navigate to your project directory**:
   ```bash
   cd /path/to/your/wordpress/project
   ```

3. **Initialize DDEV for WordPress**:
   ```bash
   ddev config --project-name=your-project-name --project-type=wordpress --docroot=web --create-docroot
   ```

4. **Configure wp-config.php** (if you have an existing one):
   Add this snippet to your `wp-config.php` before the `wp-settings.php` line:
   ```php
   // Include for ddev-managed settings in wp-config-ddev.php.
   $ddev_settings = dirname(__FILE__) . '/wp-config-ddev.php';
   if (is_readable($ddev_settings) && !defined('DB_USER')) {
     require_once($ddev_settings);
   }
   ```

5. **Add the Kanopi WordPress addon**:
   ```bash
   ddev add-on get kanopi/ddev-kanopi-wp
   ```

6. **Start DDEV**:
   ```bash
   ddev start
   ```

7. **Set up Pantheon token** (if using Pantheon):
   ```bash
   ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
   ddev restart
   ```

8. **Import your database** (if from Pantheon):
   ```bash
   ddev refresh
   ```

### Quick Start

After installation, configure and initialize your development environment:

```bash
# 1. Configure your project settings (interactive wizard)
ddev project:configure

# 2. Initialize your complete development environment
ddev init
```

**`ddev project:configure`** - Interactive setup wizard that prompts you for:

1. **Hosting Provider**: Pantheon, WPEngine, or Kinsta
2. **WordPress Admin**: Username, password, and email
3. **Hosting Details**: Site-specific configuration (e.g., Pantheon site name)
4. **Theme Configuration**: Theme path and name
5. **Migration Settings**: Source project for database migrations (optional)

**`ddev init`** - Complete development environment setup that automatically:
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

### Pantheon Setup

For Pantheon users, you'll need to set your machine token **globally** (shared across all DDEV projects):

```bash
# Set your Pantheon machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here

# Restart DDEV to apply the token
ddev restart
```

**Get your token**: Visit [Pantheon's Machine Token page](https://pantheon.io/docs/machine-tokens/) to create a token.

## Configuration Management

All configuration is handled through environment variables stored in `.ddev/config.yaml`. These are set during the interactive installation or can be updated using the `ddev project:configure` command.

**Configuration is stored as environment variables:**
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

**To update configuration:**
```bash
# Use the interactive reconfiguration wizard
ddev project:configure

# Or manually update environment variables
ddev config --web-environment-add HOSTING_SITE=new-site-name
ddev restart
```

## Available Commands

| Command | Type | Description | Example | Aliases |
|---------|------|-------------|---------|---------|
| `ddev critical:install` | Web | Install Critical CSS generation tools | `ddev critical:install` | install-critical-tools, cri, critical-install |
| `ddev critical:run` | Web | Run Critical CSS generation | `ddev critical:run` | critical, crr, critical-run |
| `ddev cypress:install` | Host | Install Cypress E2E testing dependencies | `ddev cypress:install` | cyi, cypress-install, install-cypress |
| `ddev cypress:run <command>` | Host | Run Cypress commands with environment support | `ddev cypress:run open` | cy, cypress, cypress-run, cyr |
| `ddev cypress:users` | Host | Create default admin user for Cypress testing | `ddev cypress:users` | cyu, cypress-users |
| `ddev init` | Host | **Initialize complete development environment** (runs all setup commands) | `ddev init` | - |
| `ddev npm <command>` | Web | Run npm commands (automatically runs in theme directory if available) | `ddev npm run build` | - |
| `ddev open [service]` | Web | Open the site or admin in your default browser | `ddev open` or `ddev open cms` | - |
| `ddev pantheon:testenv <name> [type]` | Host | Create isolated testing environment (fresh or existing) | `ddev pantheon:testenv my-test fresh` | testenv, pantheon-testenv |
| `ddev pantheon:terminus <command>` | Host | Run Terminus commands for Pantheon integration | `ddev pantheon:terminus site:list` | terminus, pantheon-terminus |
| `ddev pantheon:tickle` | Web | Keep Pantheon environment awake during long operations | `ddev pantheon:tickle` | tickle, pantheon-tickle |
| `ddev phpcbf` | Host | Run PHP Code Beautifier and Fixer | `ddev phpcbf` | - |
| `ddev phpcs` | Host | Run PHP Code Sniffer | `ddev phpcs` | - |
| `ddev project:configure` | Host | **Interactive setup wizard** (configure project settings) | `ddev project:configure` | configure, project-configure, prc |
| `ddev refresh [env]` | Host | Pull database from hosting provider and perform local setup | `ddev refresh live` | - |
| `ddev restore-admin-user` | Web | Restore the admin user credentials | `ddev restore-admin-user` | - |
| `ddev theme:activate` | Web | Activate the custom theme | `ddev theme:activate` | activate-theme, tha, theme-activate |
| `ddev theme:build` | Web | Build production assets | `ddev theme:build` | production, theme-build, thb, theme-production |
| `ddev theme:create-block <block-name>` | Web | Create a new WordPress block with proper scaffolding | `ddev theme:create-block my-block` | create-block, thcb, theme-create-block |
| `ddev theme:install` | Web | Set up Node.js, NPM, and build tools using .nvmrc | `ddev theme:install` | install-theme-tools, thi, theme-install |
| `ddev theme:watch` | Web | Start the development server with file watching | `ddev theme:watch` | development, thw, theme-watch, theme-development |

## Services Included

All services are provided by official DDEV add-ons:

- **PHPMyAdmin**: Database management interface (via ddev/ddev-phpmyadmin)
- **Redis**: Object caching for WordPress (via ddev/ddev-redis)  
- **Solr**: Search indexing compatible with hosting providers (via ddev/ddev-solr)

## WordPress Configuration

The add-on automatically configures:
- WordPress multisite support (if needed)
- Database connection settings (auto-modifies wp-config.php)
- Redis object caching
- Solr search integration
- Admin user creation
- Theme activation
- Plugin management

## Block Development Workflow

1. Create a new block:
   ```bash
   ddev theme:create-block my-custom-block
   ```

2. Start development:
   ```bash
   ddev theme:watch
   ```

3. Your block will be created in `web/wp-content/themes/custom/struts/assets/src/blocks/my-custom-block/` with:
   - `block.json` - Block metadata
   - `index.js` - Block registration
   - `edit.js` - Editor interface
   - `save.js` - Frontend output (or `render.php` for server-side rendering)
   - `style.scss` - Frontend styles
   - `editor.scss` - Editor styles
   - `view.js` - Frontend JavaScript

## Multi-Provider Hosting Integration

The add-on supports multiple hosting platforms with provider-specific refresh capabilities:

### Pantheon
```bash
# Set your machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token

# Pull database from Pantheon
ddev refresh [environment]
```

### WPEngine  
```bash
# Configure SSH access (add your SSH key to WPEngine account)
ddev auth ssh

# Pull database from WPEngine
ddev refresh [environment]
```

### Kinsta
```bash  
# Set your API credentials globally
ddev config global --web-environment-add=KINSTA_API_KEY=your_api_key

# Pull database from Kinsta
ddev refresh [environment]
```

All refresh commands automatically:
- Download the database from your hosting provider
- Perform search/replace for local URLs  
- Activate your theme
- Restore admin user credentials

## Development Notes

- Assets are compiled using `@wordpress/scripts` and Webpack
- The `assets/build/` folder is not committed and is built during development/deployment
- Git hooks are configured via Lefthook for code quality checks
- The environment supports HTTPS with locally-trusted certificates

## Contributing

Contributions are welcome! Please ensure:
- All commands are tested in the `tests/test.bats` file
- Documentation is updated for new features
- Follow the existing code style and conventions

## Support

For issues and questions:
- Open an issue on the [GitHub repository](https://github.com/kanopi/ddev-kanopi-wp/issues)
- Check the [DDEV documentation](https://ddev.readthedocs.io/) for general DDEV questions

**Originally Contributed by [Kanopi Studios](https://kanopi.com)**