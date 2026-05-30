#!/usr/bin/env bash

# Shared configuration loader for Kanopi WordPress DDEV commands
# Manages configuration variables for hosting providers and development settings
# Usage: source this file, then call load_kanopi_config

#ddev-generated

# --------------------------------------------------------------------------
# Shared presentation constants
# --------------------------------------------------------------------------
# ANSI color escapes (use with `echo -e` or printf %b).
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'

# Reusable separator.
divider='===================================================\n'

# Emoji glyphs used by user-facing messages.
check='\xE2\x9C\x85'
crossmark='\xE2\x9D\x8C'
construction='\xF0\x9F\x9A\xA7'
party='\xF0\x9F\x8E\x88 \xF0\x9F\x8E\x89 \xF0\x9F\x8E\x8A'
reverseparty='\xF0\x9F\x8E\x8A \xF0\x9F\x8E\x89 \xF0\x9F\x8E\x88'
rocket='\xF0\x9F\x9A\x80'
lightning='\xE2\x9A\xA1'
gear='\xEF\xB8\x8F'
key='\xF0\x9F\x94\x91'
lock='\xF0\x9F\x94\x92'
arm='\xF0\x9F\x92\xAA'
hospital='\xF0\x9F\x8F\xA5'
silhouette='\xF0\x9F\x91\xA4'
drop='\xF0\x9F\x92\xA7'
shark='\xF0\x9F\xA6\x88'
database_icon='\xF0\x9F\x93\x80'
down_arrow='\xE2\xAC\x86'

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
    # Skip if already loaded in this shell — avoids redundant re-export across
    # nested commands (project-init sources this 8+ times otherwise).
    [ "${KANOPI_CONFIG_LOADED:-0}" = "1" ] && return 0

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

    # Remote SSH-specific Configuration
    if [[ "${HOSTING_PROVIDER}" == "remote" ]]; then
        export REMOTE_HOST=${REMOTE_HOST:-''}
        export REMOTE_PORT=${REMOTE_PORT:-'22'}
        export REMOTE_USER=${REMOTE_USER:-''}
        export REMOTE_PATH=${REMOTE_PATH:-''}
        export REMOTE_DOMAIN=${REMOTE_DOMAIN:-''}
    fi

    export KANOPI_CONFIG_LOADED=1
}

# Resolve the host-side docroot using DDEV's merged config view.
# Honors overrides in .ddev/config.local.yaml, .ddev/config.*.yaml, etc. —
# a plain `grep .ddev/config.yaml` would miss those. Cached in DOCROOT so a
# single project-init run only pays for one container spin-up.
# Only safe to call on the HOST (uses `ddev` and `docker` binaries).
resolve_host_docroot() {
    if [ -n "${DOCROOT:-}" ]; then
        echo "$DOCROOT"
        return 0
    fi
    local value
    value=$(ddev utility configyaml --full-yaml 2>/dev/null \
        | docker run -i --rm ddev/ddev-utilities yq '.docroot' 2>/dev/null)
    # yq prints 'null' when the key is unset; normalize to empty string.
    [ "$value" = "null" ] && value=""
    echo "$value"
}

# Standard MySQL connection details for the DDEV db container.
# Use as: mysql $KANOPI_DB_CONN -e "..."
export KANOPI_DB_CONN="-h db -u db -pdb db"

# Shared MySQL DSN string used by import commands.
export KANOPI_DB_DSN="-h db -u db -pdb db"

# Resolve the WordPress docroot path inside the web container.
# Trusts DDEV_DOCROOT (set by DDEV from the merged config) when present —
# that's the authoritative value and respects all override files. Falls back
# to HOSTING_PROVIDER + DOCROOT defaults when DDEV_DOCROOT isn't available
# (e.g. when this helper is sourced outside a normal `ddev exec` context).
# Normalizes empty / '.' to the application root.
# Usage: path=$(get_docroot_path)
get_docroot_path() {
    local docroot="${DDEV_DOCROOT-}"
    if [ -z "${DDEV_DOCROOT+x}" ]; then
        docroot="${DOCROOT:-}"
        case "${HOSTING_PROVIDER:-}" in
            kinsta)
                docroot="public"
                ;;
            pantheon|wpengine|*)
                docroot="${docroot:-web}"
                ;;
        esac
    fi
    if [ "$docroot" = "." ] || [ -z "$docroot" ]; then
        echo "/var/www/html"
    else
        echo "/var/www/html/${docroot}"
    fi
}

# Resolve the full path to the active theme inside the web container.
# Usage: path=$(get_full_theme_path)
get_full_theme_path() {
    local docroot_path
    docroot_path=$(get_docroot_path)
    echo "${docroot_path}/${THEME}"
}

# Retry a command up to N times with a fixed backoff between attempts.
# Usage: retry_command 3 ddev composer install
retry_command() {
    local max_attempts="$1"
    shift
    local attempt=1
    while [ "$attempt" -le "$max_attempts" ]; do
        if [ "$attempt" -gt 1 ]; then
            echo "⚠️  Attempt $attempt of $max_attempts (waiting 5s)..."
            sleep 5
        fi
        if "$@"; then
            return 0
        fi
        attempt=$((attempt + 1))
    done
    return 1
}

# Decide whether a cached database backup should be refreshed.
# Returns 0 (true, refresh) when the file is missing, older than max_age_hours,
# or when force=true. Returns 1 (false, reuse cache) otherwise.
# Usage: if should_refresh_backup /tmp/db.sql 12 "$FORCE_REFRESH"; then ...
should_refresh_backup() {
    local backup_file="$1"
    local max_age_hours="${2:-12}"
    local force="${3:-false}"
    local max_age_minutes=$((max_age_hours * 60))

    if [[ "$force" == "true" ]]; then
        echo "Force flag detected. Will refresh backup regardless of age."
        return 0
    fi
    if [ ! -f "$backup_file" ]; then
        echo "Backup file does not exist locally."
        return 0
    fi
    if [ -n "$(find "$backup_file" -mmin +${max_age_minutes} 2>/dev/null)" ]; then
        echo "Backup file is older than ${max_age_hours} hours."
        return 0
    fi
    local backup_age_minutes=$(( ($(date +%s) - $(stat -c %Y "$backup_file")) / 60 ))
    local backup_age_hours=$(( backup_age_minutes / 60 ))
    echo "Recent backup found (${backup_age_hours} hours old). Using existing backup."
    return 1
}

# Write the SSH public/private key matching $key_name from the agent to a temp
# file and echo its path. Returns non-zero if no matching key is loaded.
# Usage: TEMP_KEY=$(load_ssh_key_by_name "$WPENGINE_SSH_KEY") || exit 1
load_ssh_key_by_name() {
    local key_name="${1:-id_rsa}"
    local temp_key="/tmp/kanopi_ssh_key_$$"
    ssh-add -L 2>/dev/null | grep "${key_name}" > "$temp_key"
    if [ ! -s "$temp_key" ]; then
        rm -f "$temp_key"
        return 1
    fi
    chmod 600 "$temp_key" 2>/dev/null || true
    echo "$temp_key"
}

# Import a SQL dump into the local DDEV database and rewrite URLs to point at
# the local site. Detects gzipped dumps by extension. If $source_domain is
# empty the current 'home' option is read from the imported DB.
# Usage: finalize_database_import /tmp/dump.sql.gz "https://prod.example.com"
finalize_database_import() {
    local dump_file="$1"
    local source_domain="${2:-}"
    local ddev_url="${DDEV_PRIMARY_URL:-https://${DDEV_SITENAME}.ddev.site}"

    echo "Resetting database..."
    wp db reset --yes --allow-root --skip-plugins --skip-themes

    echo "Importing database from ${dump_file}..."
    if [[ "$dump_file" == *.gz ]]; then
        gunzip -c "$dump_file" | sed 's/DEFINER=`[^`]*`@`[^`]*`//g' | wp db import - --allow-root || return 1
    else
        if ! mysql ${KANOPI_DB_DSN} < "$dump_file"; then
            echo "Failed to import database"
            return 1
        fi
    fi

    if [ -z "$source_domain" ]; then
        # Detect prefix from any *_options table (handles custom WP_PREFIX).
        local table_prefix
        table_prefix=$(mysql ${KANOPI_DB_DSN} -N -B -e "SHOW TABLES LIKE '%\\_options'" 2>/dev/null | head -n 1 | sed 's/_options$//')
        if [ -n "$table_prefix" ]; then
            source_domain=$(mysql ${KANOPI_DB_DSN} -N -B -e "SELECT option_value FROM ${table_prefix}_options WHERE option_name='home' LIMIT 1;" 2>/dev/null)
        fi
    fi

    if [ -n "$source_domain" ]; then
        echo "Replacing URLs: ${source_domain} -> ${ddev_url}"
        wp search-replace "$source_domain" "$ddev_url" --all-tables --skip-columns=guid --allow-root
    else
        echo "Warning: Could not detect source URL — manual URL update may be required."
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
