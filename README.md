# ddev-kanopi-wp

[![tests](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/tests.yml/badge.svg)](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

## What is ddev-kanopi-wp?

This repository provides a DDEV add-on that configures a WordPress development environment with Kanopi's standard tooling and workflows. It includes:

- **Block Creation Tooling**: Command to generate custom WordPress blocks with proper scaffolding
- **Pantheon Integration**: Tools for pulling databases and assets from Pantheon hosting
- **Development Workflow**: Asset compilation, code quality tools, and development server setup
- **WordPress Configuration**: Pre-configured services including PHPMyAdmin, Redis, and Solr
- **Premium Plugin Support**: ACF Pro and Gravity Forms integration with license management

This add-on converts the existing Docksal-based Kanopi WordPress workflow to DDEV, providing the same functionality and commands in a DDEV environment.

## Installation

```bash
ddev add-on get kanopi/ddev-kanopi-wp
```

The installation includes an **interactive setup wizard** that will prompt you for:

1. **Hosting Provider**: Pantheon, WP Engine, or Kinsta
2. **WordPress Admin**: Username, password, and email
3. **Hosting Details**: Site-specific configuration (e.g., Pantheon site name)
4. **Plugin Licenses**: ACF Pro and Gravity Forms keys (optional)

The wizard automatically writes your configuration to `.ddev/config.kanopi.yaml`.

### Pantheon Setup

For Pantheon users, you'll need to set your machine token **globally** (shared across all DDEV projects):

```bash
# Set your Pantheon machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here

# Restart DDEV to apply the token
ddev restart
```

**Get your token**: Visit [Pantheon's Machine Token page](https://pantheon.io/docs/machine-tokens/) to create a token.

## Manual Configuration

If you skip the interactive setup or want to edit your configuration later:

```yaml
# Edit .ddev/config.kanopi.yaml
wordpress:
  admin_user: "your-admin-username"
  admin_pass: "your-admin-password"
  admin_email: "your-email@domain.com"

pantheon:  # Only if using Pantheon
  site: "your-pantheon-site-name"
  env: "dev"  # or test, live
  # Note: Machine token is set globally, not in config files

licenses:  # Optional premium plugins
  acf_client_user: "your-acf-license-key"
  gf_client_user: "your-gravity-forms-license-key"
```

### Local Configuration Overrides

A local configuration file is automatically created during installation with common settings commented out. This file is automatically added to `.gitignore` to keep personal settings private.

**To customize local settings:**

1. **Edit** `.ddev/config.kanopi.local.yaml`
2. **Uncomment** any settings you want to override
3. **Run** `ddev restart` to apply changes

**Common local overrides:**
```yaml
# .ddev/config.kanopi.local.yaml

# Enable XDebug for local debugging
development:
  xdebug_enabled: true

# Override image proxy settings
proxy:
  base_url: "https://test-your-site.pantheonsite.io"

# Override WordPress admin for local development
wordpress:
  admin_user: "localadmin"
  admin_pass: "localpass123"

# Override Pantheon environment for testing
pantheon:
  env: "test"  # or "live"
```

## Available Commands

| Command | Description |
|---------|-------------|
| `ddev create-block <block-name>` | Create a new WordPress block with proper scaffolding |
| `ddev development` | Start the development server with file watching |
| `ddev production` | Build production assets |
| `ddev refresh` | Pull database from Pantheon and perform local setup |
| `ddev activate-theme` | Activate the custom theme |
| `ddev restore-admin-user` | Restore the admin user credentials |
| `ddev phpcs` | Run PHP Code Sniffer |
| `ddev phpcbf` | Run PHP Code Beautifier and Fixer |
| `ddev npm <command>` | Run npm commands (automatically runs in theme directory if available) |
| `ddev terminus <command>` | Run Terminus commands for Pantheon integration |
| `ddev open` | Open the site in your default browser |
| `ddev open cms` | Open WordPress admin in your default browser |

## Services Included

- **PHPMyAdmin**: Database management interface (accessible via `ddev describe`)
- **Redis**: Object caching for WordPress
- **Solr**: Search indexing (compatible with Pantheon's Solr configuration)

## WordPress Configuration

The add-on automatically configures:
- WordPress multisite support (if needed)
- Database connection settings
- Redis object caching
- Solr search integration
- Admin user creation
- Theme activation
- Plugin management

## Block Development Workflow

1. Create a new block:
   ```bash
   ddev create-block my-custom-block
   ```

2. Start development:
   ```bash
   ddev development
   ```

3. Your block will be created in `web/wp-content/themes/custom/struts/assets/src/blocks/my-custom-block/` with:
   - `block.json` - Block metadata
   - `index.js` - Block registration
   - `edit.js` - Editor interface
   - `save.js` - Frontend output (or `render.php` for server-side rendering)
   - `style.scss` - Frontend styles
   - `editor.scss` - Editor styles
   - `view.js` - Frontend JavaScript

## Pantheon Integration

The add-on includes tools for working with Pantheon:

1. Configure your Pantheon settings in `.ddev/config.kanopi.yaml`
2. Pull your database: `ddev refresh`
3. The command will automatically:
   - Download the database from Pantheon
   - Perform search/replace for local URLs
   - Activate your theme
   - Restore admin user credentials

## License Management

For premium plugins (ACF Pro, Gravity Forms), provide your license keys during the interactive setup or add them to `.ddev/config.kanopi.yaml` under the `licenses` section. The add-on will automatically configure Composer authentication for these plugins.

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