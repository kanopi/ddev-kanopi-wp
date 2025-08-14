#!/bin/bash

# Shared configuration loader for Kanopi WordPress DDEV commands
# Supports local overrides via config.kanopi.local.yaml
# Usage: source this file, then call load_kanopi_config

#ddev-generated

load_kanopi_config() {
    local config_dir="$1"
    local main_config="$config_dir/config.kanopi.yaml"
    local local_config="$config_dir/config.kanopi.local.yaml"
    
    # Function to get config value with local override support
    get_config_value() {
        local key="$1"
        local default="$2"
        local value="$default"
        
        # First try to get from local config (highest priority)
        if [ -f "$local_config" ] && command -v yq >/dev/null 2>&1; then
            local local_value=$(yq eval "$key // \"\"" "$local_config" 2>/dev/null)
            if [ -n "$local_value" ] && [ "$local_value" != "null" ]; then
                value="$local_value"
            fi
        fi
        
        # If not found in local, try main config
        if [ "$value" = "$default" ] && [ -f "$main_config" ] && command -v yq >/dev/null 2>&1; then
            local main_value=$(yq eval "$key // \"\"" "$main_config" 2>/dev/null)
            if [ -n "$main_value" ] && [ "$main_value" != "null" ]; then
                value="$main_value"
            fi
        fi
        
        echo "$value"
    }
    
    # Export commonly used configuration values
    export WP_ADMIN_USER=$(get_config_value '.wordpress.admin_user' 'admin')
    export WP_ADMIN_PASS=$(get_config_value '.wordpress.admin_pass' 'admin')
    export WP_ADMIN_EMAIL=$(get_config_value '.wordpress.admin_email' 'admin@example.com')
    
    export WP_THEME_SLUG=$(get_config_value '.theme.slug' 'struts')
    export WP_THEME_RELATIVE_PATH=$(get_config_value '.theme.relative_path' 'wp-content/themes/custom/struts')
    
    export PANTHEON_SITE=$(get_config_value '.pantheon.site' '')
    export PANTHEON_ENV=$(get_config_value '.pantheon.env' 'dev')
    export PANTHEON_TOKEN=$(get_config_value '.pantheon.token' '')
    
    export ACF_CLIENT_USER=$(get_config_value '.licenses.acf_client_user' '')
    export GF_CLIENT_USER=$(get_config_value '.licenses.gf_client_user' '')
    
    export XDEBUG_ENABLED=$(get_config_value '.development.xdebug_enabled' 'false')
    
    # Debug output if requested
    if [ "$KANOPI_CONFIG_DEBUG" = "true" ]; then
        echo "Configuration loaded:"
        echo "  WordPress Admin: $WP_ADMIN_USER ($WP_ADMIN_EMAIL)"
        echo "  Theme: $WP_THEME_SLUG at $WP_THEME_RELATIVE_PATH"
        if [ -n "$PANTHEON_SITE" ]; then
            echo "  Pantheon: $PANTHEON_SITE ($PANTHEON_ENV)"
        fi
        if [ -f "$local_config" ]; then
            echo "  Using local config overrides: $local_config"
        fi
    fi
}