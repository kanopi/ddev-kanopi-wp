#!/usr/bin/env bash

## Kinsta Database Refresh Script
## Called by the main refresh command for Kinsta platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

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
KINSTA_SITE=$(printenv HOSTING_SITE 2>/dev/null)
KINSTA_SSH_HOST=$(printenv KINSTA_SSH_HOST 2>/dev/null)
KINSTA_SSH_PORT=$(printenv KINSTA_SSH_PORT 2>/dev/null)
KINSTA_SSH_USER=$(printenv KINSTA_SSH_USER 2>/dev/null)

# Check for required environment variables
if [ -z "${KINSTA_SITE:-}" ]; then
  echo -e "${red}Error: HOSTING_SITE environment variable not set. Check .ddev/config.yaml web_environment section.${NC}"
  exit 1
fi

if [ -z "${KINSTA_SSH_HOST:-}" ]; then
  echo -e "${red}Error: KINSTA_SSH_HOST environment variable not set${NC}"
  echo -e "${red}Please set this in ~/.ddev/global_config.yaml or your environment${NC}"
  echo -e "${red}Example in ~/.ddev/global_config.yaml:${NC}"
  echo -e "${red}web_environment:${NC}"
  echo -e "${red}  - KINSTA_SSH_HOST=your.kinsta.server.ip${NC}"
  exit 1
fi

if [ -z "${KINSTA_SSH_PORT:-}" ]; then
  echo -e "${red}Error: KINSTA_SSH_PORT environment variable not set${NC}"
  echo -e "${red}Please set this in ~/.ddev/global_config.yaml or your environment${NC}"
  echo -e "${red}Example in ~/.ddev/global_config.yaml:${NC}"
  echo -e "${red}web_environment:${NC}"
  echo -e "${red}  - KINSTA_SSH_PORT=60490${NC}"
  exit 1
fi

if [ -z "${KINSTA_SSH_USER:-}" ]; then
  echo -e "${red}Error: KINSTA_SSH_USER environment variable not set${NC}"
  echo -e "${red}Please set this in ~/.ddev/global_config.yaml or your environment${NC}"
  echo -e "${red}Example in ~/.ddev/global_config.yaml:${NC}"
  echo -e "${red}web_environment:${NC}"
  echo -e "${red}  - KINSTA_SSH_USER=your_kinsta_user${NC}"
  exit 1
fi

# Set up SSH connection details
REMOTE_HOST="${KINSTA_SSH_USER}@${KINSTA_SSH_HOST}"
REMOTE_PORT="${KINSTA_SSH_PORT}"
REMOTE_PATH="public"
DBFILE="/tmp/kinsta_${KINSTA_SITE}.sql"

echo -e "${green}Using Kinsta site: ${KINSTA_SITE}${NC}"
echo -e "${green}Environment: ${ENVIRONMENT}${NC}"
echo -e "${green}SSH connection: ${REMOTE_HOST}:${REMOTE_PORT}${NC}"

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
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes -p "${REMOTE_PORT}" "${REMOTE_HOST}" "echo 'SSH connection successful'" 2>/dev/null; then
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
    REMOTE_DBFILE="${KINSTA_SITE}.sql"
    if ssh -p "${REMOTE_PORT}" "${REMOTE_HOST}" "cd ${REMOTE_PATH}; wp db export ${REMOTE_DBFILE} --allow-root"; then
        echo -e "${green}Database exported successfully on remote server.${NC}"
    else
        echo -e "${red}Failed to export database on remote server${NC}"
        exit 1
    fi
    
    echo -e "${yellow}Downloading Database...${NC}"
    if rsync -arv -e "ssh -p ${REMOTE_PORT}" --progress "${REMOTE_HOST}:${REMOTE_PATH}/${REMOTE_DBFILE}" "${DBFILE}"; then
        echo -e "${green}Database downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download database${NC}"
        exit 1
    fi
    
    echo -e "${yellow}Database downloaded. Removing remote db file...${NC}"
    ssh -p "${REMOTE_PORT}" "${REMOTE_HOST}" "rm ${REMOTE_PATH}/${REMOTE_DBFILE}" || echo "Warning: Could not remove remote database file"
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
if [[ "$ENVIRONMENT" == "live" ]]; then
    SOURCE_DOMAIN=$(printenv KINSTA_LIVE_DOMAIN 2>/dev/null || echo "${KINSTA_SITE}.kinsta.cloud")
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    SOURCE_DOMAIN=$(printenv KINSTA_STAGING_DOMAIN 2>/dev/null || echo "staging-${KINSTA_SITE}.kinsta.cloud")
else
    SOURCE_DOMAIN=$(printenv KINSTA_LIVE_DOMAIN 2>/dev/null || echo "${KINSTA_SITE}.kinsta.cloud")
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
ddev activate-theme 2>/dev/null || echo "Theme activation command not available"

echo -e "${green}${divider}${NC}"
echo -e "${green}Kinsta database refresh complete!${NC}"
echo -e "${green}Site URL: ${BASIC_DDEV_URL}${NC}"
echo -e "${yellow}You should now rebuild the .htaccess file if needed.${NC}"
echo -e "${green}${divider}${NC}"