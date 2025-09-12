#!/usr/bin/env bash

## WPEngine Database Refresh Script
## Called by the main refresh command for WPEngine platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Parameters from main refresh command
ENVIRONMENT=${1:-production}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from WPEngine ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo -e "${yellow}Force refresh enabled - will download fresh backup${NC}"
fi
echo -e "${green}${divider}${NC}"

# Get WPEngine configuration from environment variables
WPENGINE_SITE=$(printenv HOSTING_SITE 2>/dev/null)

# Check for required environment variables
if [ -z "${WPENGINE_SITE:-}" ]; then
  echo -e "${red}Error: HOSTING_SITE environment variable not set. Check .ddev/config.yaml web_environment section.${NC}"
  exit 1
fi

# Use environment parameter or fall back to HOSTING_SITE
WPENGINE_ENV=${ENVIRONMENT:-$WPENGINE_SITE}
WPENGINE_SSH="$WPENGINE_ENV@$WPENGINE_ENV.ssh.wpengine.net"
WPENGINE_PATH="/home/wpe-user/sites/$WPENGINE_ENV"
WPENGINE_BACKUP_PATH="$WPENGINE_PATH/wp-content/mysql.sql"
DB_DUMP='/tmp/wpengine_db.sql'

echo -e "${green}Using WPEngine site: ${WPENGINE_SITE}${NC}"
echo -e "${green}Environment: ${WPENGINE_ENV}${NC}"
echo -e "${green}SSH connection: ${WPENGINE_SSH}${NC}"

# Change to docroot
DOCROOT="${DOCROOT:-web}"
cd "/var/www/html/${DOCROOT}"

# Check if database dump exists and is recent (12 hours = 720 minutes)
DOWNLOAD_BACKUP=false

if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force flag detected. Downloading fresh backup regardless of age.${NC}"
    DOWNLOAD_BACKUP=true
elif [ ! -f "$DB_DUMP" ]; then
    echo -e "${yellow}Database backup does not exist locally.${NC}"
    DOWNLOAD_BACKUP=true
elif [ ! -z $(find $DB_DUMP -mmin +720) ]; then
    echo -e "${yellow}Database backup is older than 12 hours.${NC}"
    DOWNLOAD_BACKUP=true
else
    BACKUP_AGE_MINUTES=$(( ($(date +%s) - $(stat -c %Y "$DB_DUMP")) / 60 ))
    BACKUP_AGE_HOURS=$(( BACKUP_AGE_MINUTES / 60 ))
    echo -e "${green}Recent backup found (${BACKUP_AGE_HOURS} hours old). Using existing backup.${NC}"
fi

if [ "$DOWNLOAD_BACKUP" = true ]; then
    echo -e "${yellow}Downloading nightly backup from WPEngine...${NC}"
    echo -e "${yellow}This may take some time. Perhaps make a refreshing beverage.${NC}"
    
    # Test SSH connectivity first
    echo -e "${yellow}Testing SSH connectivity to WPEngine...${NC}"
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$WPENGINE_SSH" "echo 'SSH connection successful'" 2>/dev/null; then
        echo -e "${red}Error: Cannot connect to WPEngine via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured with WPEngine${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to your WPEngine account${NC}"
        exit 1
    fi
    
    echo -e "${green}SSH connection successful. Downloading backup...${NC}"
    if rsync -avzh --progress "$WPENGINE_SSH:$WPENGINE_BACKUP_PATH" "$DB_DUMP"; then
        # Update timestamp to mark as fresh
        touch -d "1 second ago" "$DB_DUMP"
        echo -e "${green}Backup downloaded successfully!${NC}"
    else
        echo -e "${red}Failed to download backup from WPEngine${NC}"
        exit 1
    fi
fi

echo -e "${yellow}Importing database...${NC}"

# Reset the database
wp db reset --yes --allow-root

# Import the database
if mysql -h db -u db -pdb db < "$DB_DUMP"; then
    echo -e "${green}Database imported successfully!${NC}"
else
    echo -e "${red}Failed to import database${NC}"
    exit 1
fi

# Update domains for DDEV
echo -e "${yellow}Updating domains for DDEV environment...${NC}"
LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"
BASIC_DDEV_URL="https://$LOCAL_DOMAIN"

# Update WordPress multisite domains if they exist
mysql -h db -u db -pdb db -e "UPDATE wp_blogs SET domain = '$LOCAL_DOMAIN' WHERE blog_id = 1;" 2>/dev/null || true
mysql -h db -u db -pdb db -e "UPDATE wp_site SET domain = '$LOCAL_DOMAIN' WHERE id = 1;" 2>/dev/null || true

# Get the current home URL and perform search-replace
CURRENT_HOME=$(wp option get home --allow-root 2>/dev/null || echo "")

if [[ -n "$CURRENT_HOME" ]]; then
    echo -e "${yellow}Running search-replace: ${CURRENT_HOME} -> ${BASIC_DDEV_URL}${NC}"
    wp search-replace "$CURRENT_HOME" "$BASIC_DDEV_URL" --all-tables --allow-root
else
    echo -e "${yellow}Could not detect current home URL. Skipping search-replace.${NC}"
fi

# Standard WordPress cleanup
echo -e "${yellow}Flushing caches and rewrite rules...${NC}"
wp cache flush --allow-root
wp rewrite flush --allow-root

# Deactivate problematic plugins
echo -e "${yellow}Deactivating problematic plugins...${NC}"
wp plugin deactivate wp-health --allow-root 2>/dev/null || true

# Activate theme
echo -e "${yellow}Activating theme...${NC}"
ddev activate-theme 2>/dev/null || echo "Theme activation command not available"

# Restore admin user
echo -e "${yellow}Restoring admin user...${NC}"
ddev restore-admin-user 2>/dev/null || echo "Admin user restoration command not available"

echo -e "${green}${divider}${NC}"
echo -e "${green}WPEngine database refresh complete!${NC}"
echo -e "${green}Site URL: ${BASIC_DDEV_URL}${NC}"
echo -e "${green}${divider}${NC}"