# Installation

## For Existing DDEV Projects

```bash
# Install the add-on
ddev add-on get kanopi/ddev-kanopi-wp

# Configure your hosting provider and project settings
ddev project-configure

# Restart DDEV to apply changes
ddev restart
```

## For Projects Without DDEV

### Step 1: Install DDEV (if not already installed)

```bash
# Using Homebrew (recommended)
brew install ddev/ddev/ddev

# Install DDEV
curl -fsSL https://ddev.com/install.sh | bash

# Or using the installer script
# See: https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/
```

### Step 2: Initialize DDEV in Your Project

```bash
# Stop conflicting development tools first
# Docksal users
fin system stop

# Lando users
lando destroy

# Navigate to your WordPress project
cd /path/to/your/wordpress/project

# Initialize DDEV configuration
#
# Set docroot based on your hosting provider:
# - public (Kinsta)
# - web (Pantheon)
# - web or public or wp or... (WPEngine)
#
# Remove --create-docroot if the docroot already exists in your project.
ddev config --project-type=wordpress --docroot=public --create-docroot

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

# Configure your hosting provider and project settings
ddev project-configure
```

### Step 3: Spin up project

```bash
# Initialize
ddev project-init
```

## Post-Installation Setup

### Required Configuration Steps

#### 1. Configure Hosting Provider Authentication

**For Pantheon:**
```bash
# Set the machine token globally for all DDEV projects
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
ddev restart

# Get your token at: https://dashboard.pantheon.io/machine-token/create
```

**For WPEngine:**
```bash
# Add your SSH public key to your WPEngine User Portal
# The add-on will automatically use the specific SSH key you configured
# Note: WPEngine only allows one SSH key per account, so specify the correct one during configuration
```

**For Kinsta:**
```bash
# Add your SSH public key in MyKinsta > User Settings > SSH Keys
# Then start SSH agent in DDEV
ddev auth ssh
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
ddev theme-install --help

# Test the command in your theme directory
ddev theme-install
```

#### 5. Convert Existing Custom Commands

If you have custom DDEV commands, convert them to use the new namespace structure:

```bash
# View existing command structure
find .ddev/commands -name "*" -type f

# Copy a similar command as a template
cp .ddev/commands/web/theme-watch .ddev/commands/web/my-custom-command
```

#### 6. Configure Premium Plugin Authentication

If your project uses premium WordPress plugins, add your `auth.json` file to the project root to authorize premium plugin downloads:

```bash
# Add auth.json to your project root for premium plugin access
# This file should contain authentication credentials for premium plugin repositories
```

!!! note
    Ensure your `auth.json` file is properly configured with the necessary authentication tokens for any premium plugins your project requires. This file is typically used by Composer for accessing private repositories.

#### 7. Update Project Documentation

Update your project's README and documentation to reference the new commands and workflow.

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
# Remove the add-on completely (includes Redis for Pantheon and all 26 commands)
ddev add-on remove kanopi-wp

# Restart DDEV to apply changes
ddev restart
```

## Verification Steps

1. **Test database refresh**: `ddev db-refresh`
2. **Test theme tools**: `ddev theme-install`
3. **Verify hosting connection**: `ddev pantheon-terminus site:list` (or appropriate provider command)
4. **Test development server**: Visit your local site and check if assets load properly