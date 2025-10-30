#!/usr/bin/env bash

# Shared configuration loader for Kanopi WordPress DDEV commands
# Manages configuration variables for hosting providers and development settings
# Usage: source this file, then call load_kanopi_config

#ddev-generated

# Default configuration values
DEFAULT_WP_ADMIN_USER="admin"
DEFAULT_WP_ADMIN_PASS="admin"
DEFAULT_WP_ADMIN_EMAIL="admin@example.com"
DEFAULT_THEME="wp-content/themes/custom/struts"
DEFAULT_THEMENAME="custom/struts"
DEFAULT_HOSTING_PROVIDER="pantheon"

# Configuration file path
CONFIG_FILE="/var/www/html/.ddev/scripts/load-config.sh"

load_kanopi_config() {
    # WordPress Admin Configuration
    export WP_ADMIN_USER=${WP_ADMIN_USER:-$DEFAULT_WP_ADMIN_USER}
    export WP_ADMIN_PASS=${WP_ADMIN_PASS:-$DEFAULT_WP_ADMIN_PASS}
    export WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-$DEFAULT_WP_ADMIN_EMAIL}

    # Theme Configuration
    export THEME=${THEME:-$DEFAULT_THEME}
    export THEMENAME=${THEMENAME:-$DEFAULT_THEMENAME}

    # Hosting Provider
    export HOSTING_PROVIDER=${HOSTING_PROVIDER:-$DEFAULT_HOSTING_PROVIDER}

    # Pantheon-specific Configuration
    if [[ "${HOSTING_PROVIDER}" == "pantheon" ]]; then
        export HOSTING_SITE=${HOSTING_SITE:-''}
        export HOSTING_ENV=${HOSTING_ENV:-'dev'}
        export DOCROOT=${DOCROOT:-''}  # Pantheon default is root, but can be configured to 'web'
        # Migration Configuration for Pantheon
        export MIGRATE_DB_SOURCE=${MIGRATE_DB_SOURCE:-''}
        export MIGRATE_DB_ENV=${MIGRATE_DB_ENV:-''}
    fi

    # WPEngine-specific Configuration
    if [[ "${HOSTING_PROVIDER}" == "wpengine" ]]; then
        export HOSTING_SITE=${HOSTING_SITE:-''}
        export DOCROOT=${DOCROOT:-'web'}  # WPEngine default, but configurable
        export WPENGINE_SSH_KEY=${WPENGINE_SSH_KEY:-''}
    fi

    # Kinsta-specific Configuration
    if [[ "${HOSTING_PROVIDER}" == "kinsta" ]]; then
        export REMOTE_HOST=${REMOTE_HOST:-''}
        export REMOTE_PORT=${REMOTE_PORT:-''}
        export REMOTE_USER=${REMOTE_USER:-''}
        export REMOTE_PATH=${REMOTE_PATH:-'public'}
    fi
}

# Function to update configuration variables in this file
update_config() {
    local var_name="$1"
    local var_value="$2"

    # Escape special characters for sed
    var_value=$(echo "$var_value" | sed 's/[[\.*^$()+?{|]/\\&/g')

    # Update or add the variable in this file
    if grep -q "^export $var_name=" "$CONFIG_FILE"; then
        # Variable exists, update it
        sed -i.bak "s/^export $var_name=.*/export $var_name=\"$var_value\"/" "$CONFIG_FILE"
    else
        # Variable doesn't exist, add it before the load_kanopi_config function
        sed -i.bak "/^load_kanopi_config() {/i\\
export $var_name=\"$var_value\"\\
" "$CONFIG_FILE"
    fi

    # Remove backup file
    rm -f "${CONFIG_FILE}.bak"

    # Export the variable immediately
    export "$var_name"="$var_value"
}
