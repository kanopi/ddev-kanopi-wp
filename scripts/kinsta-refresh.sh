#!/usr/bin/env bash
#ddev-generated

## Kinsta Database Refresh Script
## Called by the main refresh command for Kinsta platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Parameters from main refresh command
ENVIRONMENT=${1:-live}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from Kinsta ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo -e "${yellow}Force refresh enabled - will export fresh database${NC}"
fi
echo -e "${green}${divider}${NC}"

# Get Kinsta configuration from environment variables
KINSTA_SSH_HOST=$(printenv REMOTE_HOST 2>/dev/null)
KINSTA_SSH_PORT=$(printenv REMOTE_PORT 2>/dev/null)
KINSTA_SSH_USER=$(printenv REMOTE_USER 2>/dev/null)
KINSTA_REMOTE_PATH=$(printenv REMOTE_PATH 2>/dev/null)

# Check for required environment variables
if [ -z "${KINSTA_SSH_HOST:-}" ]; then
  echo -e "${red}Error: REMOTE_HOST not configured. Run 'ddev project-configure' to set up your Kinsta SSH configuration.${NC}"
  exit 1
fi

if [ -z "${KINSTA_SSH_PORT:-}" ]; then
  echo -e "${red}Error: REMOTE_PORT not configured. Run 'ddev project-configure' to set up your Kinsta SSH configuration.${NC}"
  exit 1
fi

if [ -z "${KINSTA_SSH_USER:-}" ]; then
  echo -e "${red}Error: REMOTE_USER not configured. Run 'ddev project-configure' to set up your Kinsta SSH configuration.${NC}"
  exit 1
fi

if [ -z "${KINSTA_REMOTE_PATH:-}" ]; then
  echo -e "${red}Error: REMOTE_PATH not configured. Run 'ddev project-configure' to set up your Kinsta SSH configuration.${NC}"
  exit 1
fi

# Set up SSH connection details
SSH_CONNECTION="${KINSTA_SSH_USER}@${KINSTA_SSH_HOST}"
SSH_PORT="${KINSTA_SSH_PORT}"
REMOTE_PATH="${KINSTA_REMOTE_PATH}"
DBFILE="/tmp/kinsta_${KINSTA_SSH_USER}.sql"

echo -e "${green}Using Kinsta SSH connection: ${SSH_CONNECTION}:${SSH_PORT}${NC}"
echo -e "${green}Environment: ${ENVIRONMENT}${NC}"
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
    
    echo -e "${yellow}Exporting ${KINSTA_SITE} Database...${NC}"
    
    # Clean up any existing files
    rm -rf ${DBFILE} || true
    rm -rf ${DBFILE}.gz || true
    
    # Test SSH connectivity first
    echo -e "${yellow}Testing SSH connectivity to Kinsta...${NC}"
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "echo 'SSH connection successful'" 2>/dev/null; then
        echo -e "${red}Error: Cannot connect to Kinsta via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured with Kinsta${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to your Kinsta account${NC}"
        echo -e "${red}4. SSH connection details are correct${NC}"
        exit 1
    fi
    
    echo -e "${green}SSH connection successful.${NC}"
    echo -e "${yellow}Using ssh on the server to access WP-CLI commands...${NC}"
    echo -e "${yellow}Exporting the remote database...${NC}"
    
    # Export database on remote server
    REMOTE_DBFILE="${KINSTA_SSH_USER}.sql"

    # Ensure REMOTE_PATH starts with / for absolute path
    if [[ ! "$REMOTE_PATH" = /* ]]; then
        REMOTE_PATH="/${REMOTE_PATH}"
    fi

    # Try to cd to the path and run wp db export, with fallback if path doesn't exist
    echo -e "${yellow}Attempting to access remote path: ${REMOTE_PATH}${NC}"
    if ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "cd ${REMOTE_PATH} && pwd && wp db export ${REMOTE_DBFILE} --allow-root"; then
        echo -e "${green}Database exported successfully on remote server.${NC}"
    else
        echo -e "${yellow}Primary path failed, trying parent directory...${NC}"
        PARENT_PATH=$(dirname "$REMOTE_PATH")
        echo -e "${yellow}Trying parent path: ${PARENT_PATH}${NC}"
        if ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "cd ${PARENT_PATH} && pwd && wp db export ${REMOTE_DBFILE} --path=${REMOTE_PATH} --allow-root"; then
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
    if rsync -arv -e "ssh -o StrictHostKeyChecking=no -p ${SSH_PORT}" --progress "${SSH_CONNECTION}:${REMOTE_PATH}/${REMOTE_DBFILE}" "${DBFILE}"; then
        echo -e "${green}Database downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download database${NC}"
        exit 1
    fi
    
    echo -e "${yellow}Database downloaded. Removing remote db file...${NC}"
    ssh -o StrictHostKeyChecking=no -p "${SSH_PORT}" "${SSH_CONNECTION}" "rm ${REMOTE_PATH}/${REMOTE_DBFILE}" || echo "Warning: Could not remove remote database file"
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

# Determine source domains based on environment
# For Kinsta, we need the user to configure the domain since it varies by site
if [[ "$ENVIRONMENT" == "live" ]]; then
    SOURCE_DOMAIN=$(printenv KINSTA_LIVE_DOMAIN 2>/dev/null || echo "${KINSTA_SSH_USER}.kinsta.cloud")
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    SOURCE_DOMAIN=$(printenv KINSTA_STAGING_DOMAIN 2>/dev/null || echo "staging-${KINSTA_SSH_USER}.kinsta.cloud")
else
    SOURCE_DOMAIN=$(printenv KINSTA_LIVE_DOMAIN 2>/dev/null || echo "${KINSTA_SSH_USER}.kinsta.cloud")
fi

echo -e "${yellow}Replacing domains: ${SOURCE_DOMAIN} -> ${LOCAL_DOMAIN}${NC}"
wp search-replace "$SOURCE_DOMAIN" "$LOCAL_DOMAIN" --all-tables --allow-root

# Standard WordPress cleanup
echo -e "${yellow}Flushing caches and rewrite rules...${NC}"
wp cache flush --allow-root 2>/dev/null || true
wp rewrite flush --allow-root

echo -e "${yellow}Fixing files directory permissions...${NC}"
chmod -R 755 wp-content/uploads 2>/dev/null || true

echo -e "${yellow}Disabling plugins for local development...${NC}"
wp plugin deactivate ithemes-security-pro autoptimize wp-health --allow-root --quiet 2>/dev/null || true

# Restore admin user
echo -e "${yellow}Verifying admin user...${NC}"
ddev restore-admin-user 2>/dev/null || echo "Admin user restoration command not available"

# Activate theme
echo -e "${yellow}Activating theme...${NC}"
ddev theme:activate 2>/dev/null || echo "Theme activation command not available"

echo -e "${green}${divider}${NC}"
echo -e "${green}Kinsta database refresh complete!${NC}"
echo -e "${green}Site URL: ${BASIC_DDEV_URL}${NC}"
echo -e "${yellow}You should now rebuild the .htaccess file if needed.${NC}"
echo -e "${green}${divider}${NC}"
