#!/usr/bin/env bash

## Remote SSH Database Refresh Script
## Called by the main refresh command for generic SSH-based hosting providers

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Parameters from main refresh command
# Note: Remote provider doesn't use environment parameter (single environment only)
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from Remote SSH host${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo -e "${yellow}Force refresh enabled - will export fresh database${NC}"
fi
echo -e "${green}${divider}${NC}"

# Get Remote SSH configuration from environment variables
REMOTE_SSH_HOST=$(printenv REMOTE_HOST 2>/dev/null)
REMOTE_SSH_PORT=$(printenv REMOTE_PORT 2>/dev/null)
REMOTE_SSH_USER=$(printenv REMOTE_USER 2>/dev/null)
REMOTE_SITE_PATH=$(printenv REMOTE_PATH 2>/dev/null)
REMOTE_SOURCE_DOMAIN=$(printenv REMOTE_DOMAIN 2>/dev/null)

# Check for required environment variables
if [ -z "${REMOTE_SSH_HOST:-}" ]; then
  echo -e "${red}Error: REMOTE_HOST not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
  exit 1
fi

if [ -z "${REMOTE_SSH_PORT:-}" ]; then
  echo -e "${red}Error: REMOTE_PORT not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
  exit 1
fi

if [ -z "${REMOTE_SSH_USER:-}" ]; then
  echo -e "${red}Error: REMOTE_USER not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
  exit 1
fi

if [ -z "${REMOTE_SITE_PATH:-}" ]; then
  echo -e "${red}Error: REMOTE_PATH not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
  exit 1
fi

if [ -z "${REMOTE_SOURCE_DOMAIN:-}" ]; then
  echo -e "${red}Error: REMOTE_DOMAIN not configured. Run 'ddev project-configure' to set up your Remote SSH configuration.${NC}"
  exit 1
fi

# Set up SSH connection details
SSH_CONNECTION="${REMOTE_SSH_USER}@${REMOTE_SSH_HOST}"
SSH_PORT="${REMOTE_SSH_PORT}"
REMOTE_PATH="${REMOTE_SITE_PATH}"
DBFILE="/tmp/remote_${REMOTE_SSH_USER}.sql"

echo -e "${green}Using Remote SSH connection: ${SSH_CONNECTION}:${SSH_PORT}${NC}"
echo -e "${green}Remote path: ${REMOTE_PATH}${NC}"

# Change to docroot
DOCROOT="${DOCROOT:-web}"
cd "/var/www/html/${DOCROOT}"

# Check if database dump exists and is recent (12 hours = 720 minutes)
EXPORT_DATABASE=false

if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force flag detected. Exporting fresh database regardless of age.${NC}"
    EXPORT_DATABASE=true
elif [ ! -f "$DBFILE" ]; then
    echo -e "${yellow}Database file does not exist locally.${NC}"
    EXPORT_DATABASE=true
elif [ ! -z $(find $DBFILE -mmin +720) ]; then
    echo -e "${yellow}Database file is older than 12 hours.${NC}"
    EXPORT_DATABASE=true
else
    BACKUP_AGE_MINUTES=$(( ($(date +%s) - $(stat -c %Y "$DBFILE")) / 60 ))
    BACKUP_AGE_HOURS=$(( BACKUP_AGE_MINUTES / 60 ))
    echo -e "${green}Recent database export found (${BACKUP_AGE_HOURS} hours old). Using existing export.${NC}"
fi

if [ "$EXPORT_DATABASE" = true ]; then
    echo -e "${yellow}You might want to get a snack or a drink. The database for this project takes a bit to export and download.${NC}"

    echo -e "${yellow}Exporting remote database...${NC}"

    # Clean up any existing files
    rm -rf ${DBFILE} || true
    rm -rf ${DBFILE}.gz || true

    # Test SSH connectivity first
    echo -e "${yellow}Testing SSH connectivity to remote host...${NC}"

    # Load SSH key
    SSH_CMD="ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p ${SSH_PORT}"
    TEMP_KEY="/tmp/temp_key"
    ssh-add -L | grep "${REMOTE_SSH_KEY:-id_rsa}" > "$TEMP_KEY"
    if eval "$SSH_CMD -i ${TEMP_KEY} ${SSH_CONNECTION} 'echo SSH connection successful'"; then
        echo -e "${green}SSH connection successful.${NC}"
    else
        echo -e "${red}Error: Cannot connect to remote host via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured on the remote server${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to the remote server's ~/.ssh/authorized_keys${NC}"
        echo -e "${red}4. Key name is set in config.local.yml: REMOTE_SSH_KEY=your_key_name${NC}"
        exit 1
    fi

    echo -e "${yellow}Using ssh on the server to access WP-CLI commands...${NC}"
    echo -e "${yellow}Exporting the remote database...${NC}"

    # Export database on remote server
    REMOTE_DBFILE="remote_export.sql"

    # Ensure REMOTE_PATH starts with / for absolute path
    if [[ ! "$REMOTE_PATH" = /* ]]; then
        REMOTE_PATH="/${REMOTE_PATH}"
    fi

    # Try to cd to the path and run wp db export, with fallback if path doesn't exist
    echo -e "${yellow}Attempting to access remote path: ${REMOTE_PATH}${NC}"
    if eval "$SSH_CMD -i ${TEMP_KEY} ${SSH_CONNECTION} 'cd ${REMOTE_PATH} && pwd && wp db export ${REMOTE_DBFILE} --allow-root'"; then
        echo -e "${green}Database exported successfully on remote server.${NC}"
    else
        echo -e "${yellow}Primary path failed, trying parent directory...${NC}"
        PARENT_PATH=$(dirname "$REMOTE_PATH")
        echo -e "${yellow}Trying parent path: ${PARENT_PATH}${NC}"
        if eval "$SSH_CMD -i ${TEMP_KEY} ${SSH_CONNECTION} 'cd ${PARENT_PATH} && pwd && wp db export ${REMOTE_DBFILE} --path=${REMOTE_PATH} --allow-root'"; then
            echo -e "${green}Database exported successfully from parent directory.${NC}"
            # Update REMOTE_PATH for download step
            REMOTE_PATH="${PARENT_PATH}"
        else
            echo -e "${red}Failed to export database on remote server${NC}"
            echo -e "${red}Tried paths: ${REMOTE_PATH} and ${PARENT_PATH}${NC}"
            exit 1
        fi
    fi

    echo -e "${yellow}Downloading Database...${NC}"
    # Build rsync command with SSH key
    RSYNC_CMD="rsync -arv --progress -e 'ssh -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${TEMP_KEY}'"
    if eval "$RSYNC_CMD \"${SSH_CONNECTION}:${REMOTE_PATH}/${REMOTE_DBFILE}\" \"${DBFILE}\""; then
        echo -e "${green}Database downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download database${NC}"
        exit 1
    fi

    echo -e "${yellow}Database downloaded. Removing remote db file...${NC}"
    eval "$SSH_CMD -i ${TEMP_KEY} ${SSH_CONNECTION} 'rm ${REMOTE_PATH}/${REMOTE_DBFILE}'" || echo "Warning: Could not remove remote database file"
fi

echo -e "${yellow}Importing Database...${NC}"

# Reset and import database
wp db reset --yes --allow-root

if mysql -h db -u db -pdb db < "${DBFILE}"; then
    echo -e "${green}Database imported successfully!${NC}"
else
    echo -e "${red}Failed to import database${NC}"
    exit 1
fi

echo -e "${yellow}Running search and replace for domains...${NC}"
LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"
BASIC_DDEV_URL="https://$LOCAL_DOMAIN"

# Replace HTTPS to HTTP first to handle SSL differences
wp search-replace "https://" "http://" --include-columns=option_value --allow-root --quiet || true

# Use the configured REMOTE_DOMAIN for search-replace
SOURCE_DOMAIN="${REMOTE_SOURCE_DOMAIN}"
if [ -z "$SOURCE_DOMAIN" ]; then
    echo -e "${red}Error: REMOTE_DOMAIN not configured. Cannot perform domain replacement.${NC}"
    exit 1
fi

echo -e "${yellow}Replacing domains: ${SOURCE_DOMAIN} -> ${LOCAL_DOMAIN}${NC}"
wp search-replace "$SOURCE_DOMAIN" "$LOCAL_DOMAIN" --all-tables --allow-root

echo -e "${yellow}Fixing files directory permissions...${NC}"
chmod -R 755 wp-content/uploads 2>/dev/null || true

echo -e "${green}${divider}${NC}"
echo -e "${green}Remote SSH database refresh complete!${NC}"
echo -e "${green}Site URL: ${BASIC_DDEV_URL}${NC}"
echo -e "${yellow}You should now rebuild the .htaccess file if needed.${NC}"
echo -e "${green}${divider}${NC}"
