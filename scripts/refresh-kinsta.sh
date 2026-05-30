#!/usr/bin/env bash
#ddev-generated

## Kinsta Database Refresh Script
## Called by the main refresh command for Kinsta platforms

# Colors / divider / emojis come from load-config.sh (sourced below).
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

ENVIRONMENT=${1:-live}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from Kinsta ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force refresh enabled - will export fresh database${NC}"
fi
echo -e "${green}${divider}${NC}"

# Validate required config vars (already loaded by load_kanopi_config).
for v in REMOTE_HOST REMOTE_PORT REMOTE_USER REMOTE_PATH; do
    if [ -z "${!v:-}" ]; then
        echo -e "${red}Error: ${v} not configured. Run 'ddev project-configure' to set up your Kinsta SSH configuration.${NC}"
        exit 1
    fi
done

SSH_CONNECTION="${REMOTE_USER}@${REMOTE_HOST}"
SSH_PORT="${REMOTE_PORT}"
DBFILE="/tmp/kinsta_${REMOTE_USER}.sql"

echo -e "${green}Using Kinsta SSH connection: ${SSH_CONNECTION}:${SSH_PORT}${NC}"
echo -e "${green}Environment: ${ENVIRONMENT}${NC}"
echo -e "${green}Remote path: ${REMOTE_PATH}${NC}"

cd "$(get_docroot_path)"

# Shared 12h-threshold backup-age decision.
if should_refresh_backup "$DBFILE" 12 "$FORCE_REFRESH"; then
    echo -e "${yellow}You might want to get a snack or a drink. The database for this project takes a bit to export and download.${NC}"

    rm -f "${DBFILE}" "${DBFILE}.gz"

    echo -e "${yellow}Testing SSH connectivity to Kinsta...${NC}"
    if ! ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "echo 'SSH connection successful'"; then
        echo -e "${red}Error: Cannot connect to Kinsta via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured with Kinsta${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to your Kinsta account${NC}"
        echo -e "${red}4. SSH connection details are correct${NC}"
        exit 1
    fi
    echo -e "${green}SSH connection successful.${NC}"

    REMOTE_DBFILE="${REMOTE_USER}.sql"

    if [[ ! "$REMOTE_PATH" = /* ]]; then
        REMOTE_PATH="/${REMOTE_PATH}"
    fi

    echo -e "${yellow}Attempting to access remote path: ${REMOTE_PATH}${NC}"
    if ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "cd ${REMOTE_PATH} && pwd && wp db export ${REMOTE_DBFILE} --allow-root"; then
        echo -e "${green}Database exported successfully on remote server.${NC}"
    else
        echo -e "${yellow}Primary path failed, trying parent directory...${NC}"
        PARENT_PATH=$(dirname "$REMOTE_PATH")
        if ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "cd ${PARENT_PATH} && pwd && wp db export ${REMOTE_DBFILE} --path=${REMOTE_PATH} --allow-root"; then
            echo -e "${green}Database exported successfully from parent directory.${NC}"
            REMOTE_PATH="${PARENT_PATH}"
        else
            echo -e "${red}Failed to export database on remote server${NC}"
            exit 1
        fi
    fi

    echo -e "${yellow}Downloading Database...${NC}"
    if rsync -arv -e "ssh -o StrictHostKeyChecking=no -p ${SSH_PORT}" --progress "${SSH_CONNECTION}:${REMOTE_PATH}/${REMOTE_DBFILE}" "${DBFILE}"; then
        echo -e "${green}Database downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download database${NC}"
        exit 1
    fi

    ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "rm ${REMOTE_PATH}/${REMOTE_DBFILE}" || echo "Warning: Could not remove remote database file"
fi

# Determine source domain for Kinsta search-replace before calling shared helper.
if [[ "$ENVIRONMENT" == "staging" ]]; then
    SOURCE_DOMAIN="${KINSTA_STAGING_DOMAIN:-staging-${REMOTE_USER}.kinsta.cloud}"
else
    SOURCE_DOMAIN="${KINSTA_LIVE_DOMAIN:-${REMOTE_USER}.kinsta.cloud}"
fi

# https → http normalization is a Kinsta-specific quirk that doesn't fit the shared finalizer.
finalize_database_import "${DBFILE}" "$SOURCE_DOMAIN"
wp search-replace "https://" "http://" --include-columns=option_value --allow-root --quiet || true

echo -e "${yellow}Fixing files directory permissions...${NC}"
chmod -R 755 wp-content/uploads 2>/dev/null || true

LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"
echo -e "${green}${divider}${NC}"
echo -e "${green}Kinsta database refresh complete!${NC}"
echo -e "${green}Site URL: https://${LOCAL_DOMAIN}${NC}"
echo -e "${yellow}You should now rebuild the .htaccess file if needed.${NC}"
echo -e "${green}${divider}${NC}"
