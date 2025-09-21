#!/usr/bin/env bash
#ddev-generated

## WPEngine Database Refresh Script
## Called by the main refresh command for WPEngine platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Parameters from main refresh command
# WPEngine doesn't really use "environments" like Pantheon - it's just different installs
# So we use the install name directly
ENVIRONMENT=${1:-$HOSTING_SITE}
FORCE_REFRESH=${2:-false}

echo -e "${green}${divider}${NC}"
echo -e "${green}Refreshing database from WPEngine ${ENVIRONMENT} environment${NC}"
if [[ "$FORCE_REFRESH" == "true" ]]; then
  echo -e "${yellow}Force refresh enabled - will download fresh backup${NC}"
fi
echo -e "${green}${divider}${NC}"

# Check for required environment variables
if [ -z "${HOSTING_SITE:-}" ]; then
  echo -e "${red}Error: HOSTING_SITE not configured. Run 'ddev project-configure' to set up your WPEngine configuration.${NC}"
  exit 1
fi

# For WPEngine, the "environment" is actually just the install name
# Users can optionally pass a different install name as the first parameter
WPENGINE_INSTALL=${ENVIRONMENT:-$HOSTING_SITE}
WPENGINE_SSH="$WPENGINE_INSTALL@$WPENGINE_INSTALL.ssh.wpengine.net"
WPENGINE_PATH="/home/wpe-user/sites/$WPENGINE_INSTALL"
WPENGINE_BACKUP_PATH="$WPENGINE_PATH/wp-content/mysql.sql"
DB_DUMP="/tmp/wpengine_${WPENGINE_INSTALL}.sql"

echo -e "${green}Using WPEngine install: ${WPENGINE_INSTALL}${NC}"
echo -e "${green}SSH connection: ${WPENGINE_SSH}${NC}"
echo -e "${green}Backup path: ${WPENGINE_BACKUP_PATH}${NC}"

# Change to docroot
DOCROOT="${DOCROOT:-web}"
cd "/var/www/html/${DOCROOT}"

# Check if database dump exists and is recent (6 hours = 360 minutes)
# WPEngine creates nightly backups, so 6 hours is reasonable
DOWNLOAD_BACKUP=false

if [[ "$FORCE_REFRESH" == "true" ]]; then
    echo -e "${yellow}Force flag detected. Downloading fresh backup regardless of age.${NC}"
    DOWNLOAD_BACKUP=true
elif [ ! -f "$DB_DUMP" ]; then
    echo -e "${yellow}Database backup does not exist locally.${NC}"
    DOWNLOAD_BACKUP=true
elif [ ! -z $(find $DB_DUMP -mmin +360) ]; then
    echo -e "${yellow}Database backup is older than 6 hours.${NC}"
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

    # Build SSH command with key if specified
    SSH_CMD="ssh -o ConnectTimeout=10 -o BatchMode=yes"
    if [ -n "${WPENGINE_SSH_KEY:-}" ] && [ -f "${WPENGINE_SSH_KEY}" ]; then
        SSH_CMD="$SSH_CMD -i ${WPENGINE_SSH_KEY}"
    fi

    if ! $SSH_CMD "$WPENGINE_SSH" "echo 'SSH connection successful'" 2>/dev/null; then
        echo -e "${red}Error: Cannot connect to WPEngine via SSH${NC}"
        echo -e "${red}Please ensure:${NC}"
        echo -e "${red}1. Your SSH key is properly configured with WPEngine${NC}"
        echo -e "${red}2. SSH agent is running: ddev auth ssh${NC}"
        echo -e "${red}3. Your key is added to your WPEngine account${NC}"
        exit 1
    fi
    
    echo -e "${green}SSH connection successful. Downloading backup...${NC}"

    # Build rsync command with SSH key if specified
    RSYNC_CMD="rsync -avzh --progress"
    if [ -n "${WPENGINE_SSH_KEY:-}" ] && [ -f "${WPENGINE_SSH_KEY}" ]; then
        RSYNC_CMD="$RSYNC_CMD -e 'ssh -i ${WPENGINE_SSH_KEY}'"
    fi

    if eval "$RSYNC_CMD \"$WPENGINE_SSH:$WPENGINE_BACKUP_PATH\" \"$DB_DUMP\""; then
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
DDEV_URL="https://$LOCAL_DOMAIN"

# Get the current home URL directly from database to avoid WordPress bootstrap issues
echo -e "${yellow}Detecting current home URL from database...${NC}"
MYSQL_CONNECTION_DETAILS="-h db -u db -pdb db"

# Try to get home URL from wp_options table (most common case)
CURRENT_HOME=$(mysql $MYSQL_CONNECTION_DETAILS -e "SELECT option_value FROM wp_options WHERE option_name = 'home' LIMIT 1" 2>/dev/null | tail -n 1)

# If that didn't work, try with different table prefix
if [[ -z "$CURRENT_HOME" || "$CURRENT_HOME" == "option_value" ]]; then
    # Get the table prefix by looking for any options table
    TABLE_PREFIX=$(mysql $MYSQL_CONNECTION_DETAILS -e "SHOW TABLES LIKE '%_options'" 2>/dev/null | head -n 1 | sed 's/_options$//')
    if [[ -n "$TABLE_PREFIX" ]]; then
        echo -e "${yellow}Found table prefix: ${TABLE_PREFIX}_${NC}"
        CURRENT_HOME=$(mysql $MYSQL_CONNECTION_DETAILS -e "SELECT option_value FROM ${TABLE_PREFIX}_options WHERE option_name = 'home' LIMIT 1" 2>/dev/null | tail -n 1)
    fi
fi

if [[ -n "$CURRENT_HOME" && "$CURRENT_HOME" != "option_value" ]]; then
    echo -e "${yellow}Replacing URLs from ${CURRENT_HOME} to ${DDEV_URL}${NC}"

    # Use WP-CLI search-replace which handles serialized data properly
    wp search-replace "$CURRENT_HOME" "$DDEV_URL" --all-tables --allow-root

    # Also update multisite domains if they exist
    mysql $MYSQL_CONNECTION_DETAILS -e "UPDATE wp_blogs SET domain = '$LOCAL_DOMAIN' WHERE blog_id = 1;" 2>/dev/null || true
    mysql $MYSQL_CONNECTION_DETAILS -e "UPDATE wp_site SET domain = '$LOCAL_DOMAIN' WHERE id = 1;" 2>/dev/null || true
    mysql $MYSQL_CONNECTION_DETAILS -e "UPDATE ${TABLE_PREFIX}_blogs SET domain = '$LOCAL_DOMAIN' WHERE blog_id = 1;" 2>/dev/null || true
    mysql $MYSQL_CONNECTION_DETAILS -e "UPDATE ${TABLE_PREFIX}_site SET domain = '$LOCAL_DOMAIN' WHERE id = 1;" 2>/dev/null || true
else
    echo -e "${yellow}Could not detect current home URL from database. Using WP-CLI fallback...${NC}"
    # Fallback to WP-CLI if database detection fails
    CURRENT_HOME=$(wp option get home --allow-root 2>/dev/null || echo "")
    if [[ -n "$CURRENT_HOME" ]]; then
        echo -e "${yellow}Running search-replace: ${CURRENT_HOME} -> ${DDEV_URL}${NC}"
        wp search-replace "$CURRENT_HOME" "$DDEV_URL" --all-tables --allow-root
    else
        echo -e "${red}Warning: Could not detect current home URL. Manual URL update may be required.${NC}"
    fi
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
ddev theme:activate 2>/dev/null || echo "Theme activation command not available"

# Restore admin user
echo -e "${yellow}Restoring admin user...${NC}"
ddev restore-admin-user 2>/dev/null || echo "Admin user restoration command not available"

echo -e "${green}${divider}${NC}"
echo -e "${green}WPEngine database refresh complete!${NC}"
echo -e "${green}Site URL: ${DDEV_URL}${NC}"
echo -e "${green}${divider}${NC}"
