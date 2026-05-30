#!/usr/bin/env bash
#ddev-generated

## WPEngine Database Refresh Script
## Called by the main refresh command for WPEngine platforms

# Colors / divider / emojis come from load-config.sh (sourced below).
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

ENVIRONMENT=${1:-$HOSTING_SITE}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from WPEngine ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force refresh enabled - will download fresh backup${NC}"
fi
echo -e "${green}${divider}${NC}"

if [ -z "${HOSTING_SITE:-}" ]; then
    echo -e "${red}Error: HOSTING_SITE not configured. Run 'ddev project-configure' to set up your WPEngine configuration.${NC}"
    exit 1
fi

WPENGINE_INSTALL=${ENVIRONMENT:-$HOSTING_SITE}
WPENGINE_SSH="$WPENGINE_INSTALL@$WPENGINE_INSTALL.ssh.wpengine.net"
WPENGINE_BACKUP_PATH="/home/wpe-user/sites/$WPENGINE_INSTALL/wp-content/mysql.sql"
DB_DUMP="/tmp/wpengine_${WPENGINE_INSTALL}.sql"

echo -e "${green}Using WPEngine install: ${WPENGINE_INSTALL}${NC}"
echo -e "${green}SSH connection: ${WPENGINE_SSH}${NC}"
echo -e "${green}Backup path: ${WPENGINE_BACKUP_PATH}${NC}"

cd "$(get_docroot_path)"

# Shared 6h-threshold backup-age decision (WPEngine creates nightly backups).
if should_refresh_backup "$DB_DUMP" 6 "$FORCE_REFRESH"; then
    echo -e "${yellow}Downloading nightly backup from WPEngine...${NC}"
    echo -e "${yellow}This may take some time. Perhaps make a refreshing beverage.${NC}"

    TEMP_KEY=$(load_ssh_key_by_name "${WPENGINE_SSH_KEY:-id_rsa}") || {
        echo -e "${red}Could not find SSH key '${WPENGINE_SSH_KEY:-id_rsa}' in the agent.${NC}"
        echo -e "${red}Run 'ddev project-auth' first.${NC}"
        exit 1
    }

    SSH_CMD="ssh -o ConnectTimeout=10 -i ${TEMP_KEY}"
    echo -e "${yellow}Testing SSH connectivity to WPEngine...${NC}"
    if $SSH_CMD "$WPENGINE_SSH" exit; then
        echo -e "${green}SSH connection successful.${NC}"
    else
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your key is added to your WPEngine account${NC}"
        echo -e "${red}2. SSH key is loaded in container: ddev auth ssh${NC}"
        echo -e "${red}3. Key name is set in config.local.yml; WPENGINE_SSH_KEY=you_key_name${NC}"
        rm -f "$TEMP_KEY"
        exit 1
    fi

    if rsync -avzh --progress -e "ssh -i ${TEMP_KEY}" "$WPENGINE_SSH:$WPENGINE_BACKUP_PATH" "$DB_DUMP"; then
        touch -d "1 second ago" "$DB_DUMP"
        echo -e "${green}Backup downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download backup from WPEngine${NC}"
        rm -f "$TEMP_KEY"
        exit 1
    fi
    rm -f "$TEMP_KEY"
fi

# Shared import + URL rewrite (auto-detects source domain).
finalize_database_import "$DB_DUMP"

LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"
# Multisite tables (best-effort — most installs aren't multisite).
mysql ${KANOPI_DB_CONN} -e "UPDATE wp_blogs SET domain = '$LOCAL_DOMAIN' WHERE blog_id = 1;" 2>/dev/null || true
mysql ${KANOPI_DB_CONN} -e "UPDATE wp_site SET domain = '$LOCAL_DOMAIN' WHERE id = 1;" 2>/dev/null || true

echo -e "${green}${divider}${NC}"
echo -e "${green}WPEngine database refresh complete!${NC}"
echo -e "${green}Site URL: https://${LOCAL_DOMAIN}${NC}"
echo -e "${green}${divider}${NC}"
