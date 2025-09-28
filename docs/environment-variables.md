# Environment Variables

Comprehensive guide to configuration variables used across all hosting providers and development workflows.

## Configuration Storage

Variables are stored in multiple locations for maximum compatibility:
- **`.ddev/config.yaml`** (web_environment section): For DDEV containers to access via `printenv`
- **`.ddev/scripts/load-config.sh`**: For command scripts to source directly
- **`.ddev/config.local.yaml`** (optional): For user-specific variables like SSH keys (git-ignored)

## Common Variables (All Providers)

These variables are used regardless of your hosting provider:

| Variable | Description | Example | Used By |
|----------|-------------|---------|---------|
| `HOSTING_PROVIDER` | Hosting platform identifier | `pantheon`, `wpengine`, `kinsta` | All commands |
| `THEME` | Path to custom theme directory | `wp-content/themes/custom/themename` | Theme commands |
| `THEMENAME` | Theme name for development tools | `mytheme` | Asset compilation |
| `WP_ADMIN_USER` | WordPress admin username | `admin` | User management |
| `WP_ADMIN_PASS` | WordPress admin password | `secure_password` | User restoration |
| `WP_ADMIN_EMAIL` | WordPress admin email | `admin@example.com` | User creation |

## Provider-Specific Variables

### Pantheon Configuration

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `HOSTING_SITE` | Pantheon site machine name | `my-wp-site` | Yes |
| `HOSTING_ENV` | Default environment for database pulls | `dev`, `test`, `live` | Yes |
| `MIGRATE_DB_SOURCE` | Source project for migrations | `source-site-name` | No |
| `MIGRATE_DB_ENV` | Source environment for migrations | `live` | No |

#### Global Pantheon Configuration
```bash
# Set globally for all DDEV projects
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
```

### WPEngine Configuration

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `HOSTING_SITE` | WPEngine install name | `mysite` | Yes |
| `WPENGINE_SSH_KEY` | Path to SSH private key (stored in local config) | `~/.ssh/id_rsa_wpengine` | Yes |

#### WPEngine SSH Key Notes
- WPEngine allows only **one SSH key per account**
- SSH key path is stored in `.ddev/config.local.yaml` to keep user-specific settings private
- Key must be added to your WPEngine User Portal
- Local config file is automatically git-ignored

### Kinsta Configuration

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `REMOTE_HOST` | SSH host (IP address or hostname) | `123.456.789.10` | Yes |
| `REMOTE_PORT` | SSH port number | `12345` | Yes |
| `REMOTE_USER` | SSH username | `mysite` | Yes |
| `REMOTE_PATH` | Remote path on server | `/www/mysite_123/public` | Yes |

#### Kinsta Path Examples
Common Kinsta path patterns:
- `/www/sitename_123/public`
- `/www/sitename_456/public_html`
- `/www/custom_path/htdocs`

## Local Configuration System

The add-on supports user-specific configuration through `.ddev/config.local.yaml` to keep personal settings separate from project-wide configuration.

### Local Configuration File

**Purpose**: Store user-specific variables like SSH key paths that should not be committed to version control.

**Location**: `.ddev/config.local.yaml` (automatically created by configuration wizard)

**Git Status**: Automatically ignored via `.gitignore`

### Example Local Configuration

```yaml
#ddev-generated
# Local configuration for user-specific settings
# This file is ignored by git to keep personal settings private

web_environment:
  - WPENGINE_SSH_KEY=/Users/username/.ssh/wpengine_key
```

### Template File

A template is provided at `config/config.local.example.yaml` showing the expected format:

```yaml
#ddev-generated
# Local configuration template for user-specific settings
# Copy this file to .ddev/config.local.yaml and customize for your environment

web_environment:
  - WPENGINE_SSH_KEY=/path/to/your/wpengine/ssh/key
```

## Configuration Management

### Setting Variables via Configuration Wizard
```bash
# Interactive configuration wizard
ddev project-configure

# This wizard will:
# 1. Detect your hosting provider
# 2. Collect provider-specific variables
# 3. Store variables in both locations
# 4. Validate configuration
```

### Manual Variable Management

#### View Current Configuration
```bash
# View all environment variables
ddev exec printenv

# View specific hosting variables
ddev exec printenv | grep -E "(HOSTING|THEME|WP_|REMOTE_)"

# View configuration script
cat .ddev/scripts/load-config.sh
```

#### Direct Variable Setting
```bash
# Set individual variables
ddev config --web-environment-add=HOSTING_PROVIDER=pantheon
ddev config --web-environment-add=HOSTING_SITE=my-site

# Restart to apply changes
ddev restart
```

## Variable Usage in Commands

### Loading Configuration in Scripts
```bash
#!/usr/bin/env bash
## Web command example

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Variables are now available
echo "Provider: $HOSTING_PROVIDER"
echo "Site: $HOSTING_SITE"
echo "Theme: $THEME"
```

### Conditional Logic Based on Provider
```bash
case "$HOSTING_PROVIDER" in
    "pantheon")
        echo "Using Pantheon-specific operations"
        terminus_command="ddev pantheon-terminus"
        ;;
    "wpengine")
        echo "Using WPEngine SSH operations"
        ssh_key="$WPENGINE_SSH_KEY"
        ;;
    "kinsta")
        echo "Using Kinsta SSH configuration"
        ssh_host="$REMOTE_HOST"
        ssh_port="$REMOTE_PORT"
        ;;
esac
```

## Environment-Specific Configurations

### Development vs Production
```bash
# Development-specific variables
WP_DEBUG=true
WP_DEBUG_LOG=true

# Production-specific variables (not set in DDEV)
WP_DEBUG=false
WP_CACHE=true
```

### Multi-Environment Support
```bash
# Default environment
HOSTING_ENV=dev

# Override for specific operations
ddev db-refresh live  # Uses live environment regardless of default
```

## Security Considerations

### Sensitive Variables
- **SSH keys**: Store paths, not the keys themselves
- **Passwords**: Use strong, unique passwords
- **Tokens**: Keep machine tokens secure and rotate regularly

### Best Practices
1. **Never commit sensitive data** to version control
2. **Use .gitignore** for local configuration files
3. **Rotate credentials** regularly
4. **Use environment-specific configurations**

## Troubleshooting Configuration

### Common Issues

#### Missing Variables
```bash
# Check if variables are set
ddev exec printenv HOSTING_PROVIDER
ddev exec printenv HOSTING_SITE

# If empty, run configuration wizard
ddev project-configure
```

#### Wrong Variable Values
```bash
# View current configuration
cat .ddev/config.yaml | grep -A 20 web_environment

# Reconfigure if needed
ddev project-configure
```

#### Configuration Script Issues
```bash
# Check if load-config.sh exists
ls -la .ddev/scripts/load-config.sh

# Source manually to test
source .ddev/scripts/load-config.sh
load_kanopi_config
echo $HOSTING_PROVIDER
```

### Debugging Commands
```bash
# Test configuration loading
ddev exec bash -c 'source /var/www/html/.ddev/scripts/load-config.sh && load_kanopi_config && env | grep -E "(HOSTING|THEME|WP_)"'

# Validate provider-specific settings
case "$HOSTING_PROVIDER" in
    "pantheon")
        ddev exec printenv TERMINUS_MACHINE_TOKEN
        ;;
    "wpengine")
        ddev exec printenv WPENGINE_SSH_KEY
        ;;
    "kinsta")
        ddev exec printenv REMOTE_HOST
        ddev exec printenv REMOTE_PORT
        ;;
esac
```

## Migration Between Providers

### Changing Hosting Providers
If you switch hosting providers, update your configuration:

```bash
# Run configuration wizard again
ddev project-configure

# Select new provider
# Enter new provider-specific variables
# Previous provider variables will be preserved but unused
```

### Cross-Provider Development
For projects that need to work with multiple providers:

```bash
# Create provider-specific configuration files
cp .ddev/scripts/load-config.sh .ddev/scripts/load-config-pantheon.sh
cp .ddev/scripts/load-config.sh .ddev/scripts/load-config-wpengine.sh

# Modify scripts for specific providers
# Source appropriate script based on current work
```

## Advanced Configuration

### Custom Variables
Add your own project-specific variables:

```bash
# Add custom variables via ddev config
ddev config --web-environment-add=CUSTOM_API_KEY=your-key
ddev config --web-environment-add=PROJECT_STAGE=development

# Use in custom commands
ddev exec printenv CUSTOM_API_KEY
```

### Configuration Templates
Create templates for common configurations:

```yaml
# .ddev/config-templates/pantheon.yaml
web_environment:
  - HOSTING_PROVIDER=pantheon
  - HOSTING_ENV=dev
  - WP_ADMIN_USER=admin
  - WP_ADMIN_EMAIL=admin@example.com
```