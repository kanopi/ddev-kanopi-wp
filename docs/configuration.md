# Configuration

The add-on uses a simple configuration approach with provider-specific variables. After installation, run the configuration wizard:

```bash
# Configure your hosting provider and project settings
ddev project-configure
```

The configuration wizard collects different information based on your hosting provider:

## Pantheon Configuration

- Site machine name (e.g., `my-site`)
- Default environment (`dev`/`test`/`live`)
- Migration source project (optional)

## WPEngine Configuration

- Install name (e.g., `my-site`)
- SSH private key path (e.g., `~/.ssh/id_rsa_wpengine`) - stored in local config
- Uses specific SSH key for authentication (WPEngine only allows one key per account)

## Kinsta Configuration

- SSH Host (e.g., IP address)
- SSH Port (e.g., `12345`)
- SSH User (e.g., `username`)
- Remote Path (e.g., `/www/somepath/public`)
- Uses SSH keys for authentication

## Common Configuration

All providers also collect:

- WordPress admin credentials
- Theme path and name

## Project Initialization

After configuration, initialize your development environment:

```bash
# Initialize your complete development environment
ddev project-init
```

**`ddev project-init`** performs the following automatically:

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

## Configuration Storage

The add-on uses a simplified configuration approach with provider-specific variables managed through `ddev project-configure`.

Variables are stored in multiple locations:

- **`.ddev/config.yaml`** (web_environment section): For DDEV containers to access via `printenv`
- **`.ddev/scripts/load-config.sh`**: For command scripts to source directly
- **`.ddev/config.local.yaml`** (optional): For user-specific variables like SSH keys (git-ignored)

## Modular Commands

The `project-init` command uses a modular approach with individual commands that can also be run separately:

```bash
# Individual setup commands (called by project-init)
ddev project-auth      # Authorize SSH keys for hosting providers
ddev project-lefthook  # Install and initialize Lefthook git hooks
ddev project-wp        # Install WordPress core and database if needed

# You can run these individually if needed
ddev project-auth      # Just setup authentication
ddev project-lefthook  # Just setup git hooks
ddev project-wp        # Just install WordPress
ddev project-configure # Configure project settings interactively
```