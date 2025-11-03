# Command Reference

This add-on provides 26+ custom commands organized into functional categories. All commands follow a consistent naming convention with aliases for convenience.

## Complete Command List

| Command | Type | Description | Example | Aliases |
|---------|------|-------------|---------|---------|
| `ddev critical-install` | Web | Install Critical CSS generation tools | `ddev critical-install` | install-critical-tools, cri, critical:install |
| `ddev critical-run` | Web | Run Critical CSS generation | `ddev critical-run` | critical, crr, critical:run |
| `ddev cypress-install` | Host | Install Cypress E2E testing dependencies | `ddev cypress-install` | cyi, cypress-install, install:cypress |
| `ddev cypress-run <command>` | Host | Run Cypress commands with environment support | `ddev cypress-run open` | cy, cypress, cypress:run, cyr |
| `ddev cypress-users` | Host | Create default admin user for Cypress testing | `ddev cypress-users` | cyu, cypress:users |
| `ddev db-prep-migrate` | Web | Create secondary database for migrations | `ddev db-prep-migrate` | migrate-prep-db, db:prep-migrate, db-mpdb |
| `ddev db-rebuild` | Host | Run composer install followed by database refresh | `ddev db-rebuild` | rebuild, db:rebuild, dbreb |
| `ddev db-refresh [env] [-f]` | Web | Smart database refresh with 12-hour backup age detection | `ddev db-refresh live -f` | refresh, db:refresh, dbref |
| `ddev pantheon-testenv <name> [type]` | Host | Create isolated testing environment (fresh or existing) | `ddev pantheon-testenv my-test fresh` | testenv, pantheon:testenv |
| `ddev pantheon-terminus <command>` | Host | Run Terminus commands for Pantheon integration | `ddev pantheon-terminus site:list` | terminus, pantheon:terminus |
| `ddev pantheon-tickle` | Web | Keep Pantheon environment awake during long operations | `ddev pantheon-tickle` | tickle, pantheon:tickle |
| `ddev project-auth` | Host | Authorize SSH keys and credentials for hosting providers | `ddev project-auth` | project:auth |
| `ddev project-configure` | Host | **Interactive setup wizard** (configure project settings) | `ddev project-configure` | configure, project:configure, prc |
| `ddev project-init` | Host | **Initialize complete development environment** (runs all setup commands) | `ddev project-init` | init, project:init |
| `ddev project-lefthook` | Host | Install and initialize Lefthook git hooks | `ddev project-lefthook` | project:lefthook |
| `ddev project-wp` | Host | Install WordPress core and database if needed | `ddev project-wp` | project:wp |
| `ddev theme-activate` | Web | Activate the custom theme | `ddev theme-activate` | activate-theme, tha, theme:activate |
| `ddev theme-build` | Web | Build production assets | `ddev theme-build` | production, theme:build, thb, theme-production |
| `ddev theme-create-block <block-name>` | Web | Create a new WordPress block with proper scaffolding | `ddev theme-create-block my-block` | create-block, thcb, theme:create-block |
| `ddev theme-install` | Web | Set up Node.js, NPM, and build tools using .nvmrc | `ddev theme-install` | install-theme-tools, thi, theme:install |
| `ddev theme-npm <command>` | Web | Run npm commands (automatically runs in theme directory if available) | `ddev theme-npm run build` | theme:npm |
| `ddev theme-npx <command>` | Web | Run NPX commands in theme directory | `ddev theme-npx webpack --watch` | npx, theme:npx |
| `ddev theme-watch` | Web | Start the development server with file watching | `ddev theme-watch` | development, thw, theme:watch, theme-development |
| `ddev wp-open [service]` | Host | Open the site or admin in your default browser | `ddev wp-open` or `ddev wp-open admin` | open, wp:open |
| `ddev wp-restore-admin-user` | Web | Restore the admin user credentials | `ddev wp-restore-admin-user` | restore-admin-user, wp:restore-admin-user |

## Command Categories

### Project Initialization
- `ddev project-init` - Master command that orchestrates complete setup
- `ddev project-configure` - Interactive configuration wizard
- `ddev project-auth` - Set up hosting provider authentication
- `ddev project-lefthook` - Initialize git hooks
- `ddev project-wp` - Install WordPress core and database

### Database Operations
- `ddev db-refresh [env] [-f]` - Smart database refresh with age detection
- `ddev db-rebuild` - Composer install + database refresh
- `ddev db-prep-migrate` - Prepare secondary database for migrations

### Theme Development
- `ddev theme-install` - Set up Node.js and build tools
- `ddev theme-watch` - Development server with file watching
- `ddev theme-build` - Production asset compilation
- `ddev theme-create-block <name>` - Generate WordPress blocks
- `ddev theme-activate` - Activate configured theme
- `ddev theme-npm <command>` - Run npm commands in theme directory
- `ddev theme-npx <command>` - Run npx commands in theme directory

### Testing & Quality Assurance
- `ddev cypress-install` - Set up Cypress E2E testing
- `ddev cypress-run <command>` - Execute Cypress tests
- `ddev cypress-users` - Create test users
- `ddev critical-install` - Set up Critical CSS tools
- `ddev critical-run` - Generate Critical CSS

### WordPress Management
- `ddev wp-open [service]` - Open site or admin in browser
- `ddev wp-restore-admin-user` - Restore admin user credentials

### Hosting Provider Integration
- `ddev pantheon-terminus <command>` - Pantheon Terminus commands
- `ddev pantheon-testenv <name>` - Create isolated test environments
- `ddev pantheon-tickle` - Keep environments awake

## Command Types

Commands are organized into two categories:

- **Host commands** (`commands/host/`): Execute on the host system outside containers
- **Web commands** (`commands/web/`): Execute inside the DDEV web container

## Using Aliases

Most commands include convenient aliases:

```bash
# These are equivalent
ddev project-init
ddev init

# These are equivalent
ddev theme-watch
ddev thw
ddev development

# These are equivalent
ddev db-refresh
ddev refresh
ddev dbref
```