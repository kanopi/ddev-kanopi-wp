#!/usr/bin/env bash

## Pantheon Database Refresh Script
## Called by the main refresh command for Pantheon platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Parameters from main refresh command
ENVIRONMENT=${1:-dev}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from Pantheon ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo -e "${yellow}Force refresh enabled - will create new backup${NC}"
fi
echo -e "${green}${divider}${NC}"

# Get configuration from environment variables
PANTHEON_SITE=$(printenv HOSTING_SITE 2>/dev/null)
PANTHEON_TOKEN="${TERMINUS_MACHINE_TOKEN:-}"

# Check required configuration
if [ -z "$PANTHEON_SITE" ]; then
    echo -e "${red}HOSTING_SITE environment variable not set. Check .ddev/config.yaml web_environment section.${NC}"
    exit 1
fi

if [ -z "$PANTHEON_TOKEN" ]; then
    echo -e "${red}TERMINUS_MACHINE_TOKEN is not set globally.${NC}"
    echo -e "${yellow}Please run: ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token${NC}"
    exit 1
fi

DOCROOT="${DOCROOT:-web}"
cd "/var/www/html/${DOCROOT}"

# Set the site environment for backup operations
SITE_ENV="${PANTHEON_SITE}.${ENVIRONMENT}"

# Check if terminus is available
if ! command -v terminus &> /dev/null; then
    echo -e "${yellow}Installing Terminus...${NC}"
    curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install
fi

# Authenticate with Pantheon if needed
echo -e "${yellow}Authenticating with Terminus...${NC}"
if [ -n "$PANTHEON_TOKEN" ]; then
    if ! terminus auth:login --machine-token="$PANTHEON_TOKEN"; then
        echo -e "${red}Failed to authenticate with Terminus. Please check your TERMINUS_MACHINE_TOKEN.${NC}"
        exit 1
    fi
    echo -e "${green}Successfully authenticated with Terminus.${NC}"
fi

echo "Checking for database backup on ${SITE_ENV}..."

# Check if there's a database backup and get its timestamp
LATEST_BACKUP_TIMESTAMP=$(terminus backup:list ${SITE_ENV} --element=database --format=list --field=date 2>/dev/null | head -1)

# Calculate current time and 12-hour threshold
CURRENT_TIME=$(date +%s)
TWELVE_HOURS_AGO=$((CURRENT_TIME - 43200))  # 12 hours = 43200 seconds

CREATE_NEW_BACKUP=false

# Check if force flag is set
if [ "$FORCE_REFRESH" = true ]; then
    echo -e "${yellow}Force flag detected. Creating new backup regardless of age.${NC}"
    CREATE_NEW_BACKUP=true
elif [ -z "$LATEST_BACKUP_TIMESTAMP" ]; then
    echo -e "${yellow}No database backup found.${NC}"
    CREATE_NEW_BACKUP=true
else
    # Extract integer part of timestamp for comparison
    BACKUP_TIME=${LATEST_BACKUP_TIMESTAMP%.*}
    
    if [ "$BACKUP_TIME" -lt "$TWELVE_HOURS_AGO" ]; then
        BACKUP_AGE_HOURS=$(( (CURRENT_TIME - BACKUP_TIME) / 3600 ))
        echo -e "${yellow}Latest backup is ${BACKUP_AGE_HOURS} hours old (older than 12 hours).${NC}"
        CREATE_NEW_BACKUP=true
    else
        BACKUP_AGE_HOURS=$(( (CURRENT_TIME - BACKUP_TIME) / 3600 ))
        echo -e "${green}Recent backup found (${BACKUP_AGE_HOURS} hours old): ${LATEST_BACKUP_TIMESTAMP}${NC}"
    fi
fi

if [ "$CREATE_NEW_BACKUP" = true ]; then
    echo -e "${yellow}Creating new backup for ${SITE_ENV}...${NC}"
    if terminus backup:create ${SITE_ENV} --element=database -y; then
        echo -e "${green}Backup created successfully.${NC}"
        # Wait a moment for the backup to be processed
        echo "Waiting for backup to complete..."
        sleep 10
    else
        echo -e "${red}Failed to create backup for ${SITE_ENV}. Exiting.${NC}"
        exit 1
    fi
fi

# Get the backup URL
DB_BACKUP_URL=$(terminus backup:get ${SITE_ENV} --element=database --field=url)

# Download and import database
curl -o /tmp/database.sql.gz "$DB_BACKUP_URL"
gunzip /tmp/database.sql.gz
wp db import /tmp/database.sql.gz --allow-root

echo -e "${yellow}Running search and replace for local domains...${NC}"
BASE_DOMAIN="${ENVIRONMENT}-${PANTHEON_SITE}.pantheonsite.io"
LOCAL_DOMAIN="${DDEV_SITENAME}.ddev.site"

wp search-replace "$BASE_DOMAIN" "$LOCAL_DOMAIN" --url="$BASE_DOMAIN" --all-tables --allow-root

# Flush rewrite rules
echo -e "${yellow}Flushing rewrite rules...${NC}"
wp rewrite flush --allow-root

# Deactivate problematic plugins
echo -e "${yellow}Deactivating problematic plugins...${NC}"
wp plugin deactivate wp-health --allow-root 2>/dev/null || true

# Activate theme
echo -e "${yellow}Activating theme...${NC}"
ddev activate-theme

# Restore admin user
echo -e "${yellow}Restoring admin user...${NC}"
ddev restore-admin-user

echo -e "${green}${divider}${NC}"
echo -e "${green}Pantheon database refresh complete!${NC}"
echo -e "${green}${divider}${NC}"