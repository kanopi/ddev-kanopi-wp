#!/usr/bin/env bash

## Remote SSH Database Refresh Script
## Called by the main refresh command for generic SSH-based hosting providers

# Colors / divider / emojis come from load-config.sh (sourced below).
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Note: Remote provider doesn't use environment parameter (single environment only)
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from Remote SSH host${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force refresh enabled - will export fresh database${NC}"
fi
echo -e "${green}${divider}${NC}"

for v in REMOTE_HOST REMOTE_PORT REMOTE_USER REMOTE_PATH REMOTE_DOMAIN; do
    if [ -z "${!v:-}" ]; then
        echo -e "${red}Error: ${v} not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
        exit 1
    fi
done

SSH_CONNECTION="${REMOTE_USER}@${REMOTE_HOST}"
SSH_PORT="${REMOTE_PORT}"
DBFILE="/tmp/remote_${REMOTE_USER}.sql"

echo -e "${green}Using Remote SSH connection: ${SSH_CONNECTION}:${SSH_PORT}${NC}"
echo -e "${green}Remote path: ${REMOTE_PATH}${NC}"

cd "$(get_docroot_path)"

if should_refresh_backup "$DBFILE" 12 "$FORCE_REFRESH"; then
    echo -e "${yellow}You might want to get a snack or a drink. The database for this project takes a bit to export and download.${NC}"

    rm -f "${DBFILE}" "${DBFILE}.gz"

    TEMP_KEY=$(load_ssh_key_by_name "${REMOTE_SSH_KEY:-id_rsa}") || {
        echo -e "${red}Could not find SSH key '${REMOTE_SSH_KEY:-id_rsa}' in the agent.${NC}"
        echo -e "${red}Run 'ddev auth ssh' first.${NC}"
        exit 1
    }

    SSH_CMD="ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${TEMP_KEY}"

    echo -e "${yellow}Testing SSH connectivity to remote host...${NC}"
    if $SSH_CMD "${SSH_CONNECTION}" 'echo SSH connection successful'; then
        echo -e "${green}SSH connection successful.${NC}"
    else
        echo -e "${red}Error: Cannot connect to remote host via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured on the remote server${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to the remote server's ~/.ssh/authorized_keys${NC}"
        rm -f "$TEMP_KEY"
        exit 1
    fi

    REMOTE_DBFILE="remote_export.sql"

    if [[ ! "$REMOTE_PATH" = /* ]]; then
        REMOTE_PATH="/${REMOTE_PATH}"
    fi

    echo -e "${yellow}Attempting to access remote path: ${REMOTE_PATH}${NC}"
    if $SSH_CMD "${SSH_CONNECTION}" "cd ${REMOTE_PATH} && pwd && wp db export ${REMOTE_DBFILE} --allow-root"; then
        echo -e "${green}Database exported successfully on remote server.${NC}"
    else
        echo -e "${yellow}Primary path failed, trying parent directory...${NC}"
        PARENT_PATH=$(dirname "$REMOTE_PATH")
        if $SSH_CMD "${SSH_CONNECTION}" "cd ${PARENT_PATH} && pwd && wp db export ${REMOTE_DBFILE} --path=${REMOTE_PATH} --allow-root"; then
            echo -e "${green}Database exported successfully from parent directory.${NC}"
            REMOTE_PATH="${PARENT_PATH}"
        else
            echo -e "${red}Failed to export database on remote server${NC}"
            rm -f "$TEMP_KEY"
            exit 1
        fi
    fi

    echo -e "${yellow}Downloading Database...${NC}"
    if rsync -arv --progress -e "ssh -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${TEMP_KEY}" "${SSH_CONNECTION}:${REMOTE_PATH}/${REMOTE_DBFILE}" "${DBFILE}"; then
        echo -e "${green}Database downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download database${NC}"
        rm -f "$TEMP_KEY"
        exit 1
    fi

    $SSH_CMD "${SSH_CONNECTION}" "rm ${REMOTE_PATH}/${REMOTE_DBFILE}" || echo "Warning: Could not remove remote database file"
    rm -f "$TEMP_KEY"
fi

# Shared import + URL rewrite, with explicit source domain.
finalize_database_import "${DBFILE}" "${REMOTE_DOMAIN}"
wp search-replace "https://" "http://" --include-columns=option_value --allow-root --quiet || true

echo -e "${yellow}Fixing files directory permissions...${NC}"
chmod -R 755 wp-content/uploads 2>/dev/null || true

LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"
echo -e "${green}${divider}${NC}"
echo -e "${green}Remote SSH database refresh complete!${NC}"
echo -e "${green}Site URL: https://${LOCAL_DOMAIN}${NC}"
echo -e "${yellow}You should now rebuild the .htaccess file if needed.${NC}"
echo -e "${green}${divider}${NC}"
