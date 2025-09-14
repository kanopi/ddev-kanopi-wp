#!/bin/bash

# Shared configuration loader for Kanopi WordPress DDEV commands
# Uses environment variables set during add-on installation
# Usage: source this file, then call load_kanopi_config

#ddev-generated

load_kanopi_config() {
    # Configuration is now handled entirely via environment variables
    # Set defaults for any missing values
    
    # WordPress Admin Configuration
    export WP_ADMIN_USER=${WP_ADMIN_USER:-'admin'}
    export WP_ADMIN_PASS=${WP_ADMIN_PASS:-'admin'}
    export WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-'admin@example.com'}
    
    # Theme Configuration
    export THEME=${THEME:-'wp-content/themes/custom/struts'}
    export THEMENAME=${THEMENAME:-'struts'}
    
    # Hosting Configuration
    export HOSTING_PROVIDER=${HOSTING_PROVIDER:-'pantheon'}
    export HOSTING_SITE=${HOSTING_SITE:-''}
    export HOSTING_ENV=${HOSTING_ENV:-'dev'}
    
    # Migration Configuration
    export MIGRATE_DB_SOURCE=${MIGRATE_DB_SOURCE:-''}
    export MIGRATE_DB_ENV=${MIGRATE_DB_ENV:-''}
    
    # Debug output if requested
    if [ "$KANOPI_CONFIG_DEBUG" = "true" ]; then
        echo "Configuration loaded from environment variables:"
        echo "  WordPress Admin: $WP_ADMIN_USER ($WP_ADMIN_EMAIL)"
        echo "  Theme: $THEMENAME at $THEME"
        echo "  Hosting: $HOSTING_PROVIDER ($HOSTING_SITE.$HOSTING_ENV)"
        if [ -n "$MIGRATE_DB_SOURCE" ]; then
            echo "  Migration Source: $MIGRATE_DB_SOURCE ($MIGRATE_DB_ENV)"
        fi
    fi
}