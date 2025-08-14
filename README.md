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

## Configuration

After installation, you'll need to configure your environment variables in `.ddev/.env-kanopi-wp`:

```bash
# Copy the example environment file
cp .ddev/.env-kanopi-wp-example .ddev/.env-kanopi-wp

# Edit with your specific values
# - ACF_CLIENT_USER: Your ACF Pro license key
# - GF_CLIENT_USER: Your Gravity Forms license key (if used)
# - PANTHEON_SITE: Your Pantheon site name
# - PANTHEON_ENV: Environment to pull from (dev, test, live)
```

## Available Commands

### Block Development
- `ddev create-block <block-name>` - Create a new WordPress block with proper scaffolding
- `ddev development` - Start the development server with file watching
- `ddev production` - Build production assets

### Database Management
- `ddev refresh` - Pull database from Pantheon and perform local setup
- `ddev activate-theme` - Activate the custom theme
- `ddev restore-admin-user` - Restore the admin user credentials

### Code Quality
- `ddev phpcs` - Run PHP Code Sniffer
- `ddev phpcbf` - Run PHP Code Beautifier and Fixer

### Development Tools
- `ddev npm <command>` - Run npm commands (automatically runs in theme directory if available)
- `ddev terminus <command>` - Run Terminus commands for Pantheon integration

### Utilities
- `ddev open` - Open the site in your default browser
- `ddev open cms` - Open WordPress admin in your default browser

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

1. Configure your Pantheon settings in `.ddev/.env-kanopi-wp`
2. Pull your database: `ddev refresh`
3. The command will automatically:
   - Download the database from Pantheon
   - Perform search/replace for local URLs
   - Activate your theme
   - Restore admin user credentials

## License Management

For premium plugins (ACF Pro, Gravity Forms), add your license keys to `.ddev/.env-kanopi-wp`. The add-on will automatically configure Composer authentication for these plugins.

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