#!/usr/bin/env bash
#ddev-generated

## Pantheon Database Refresh Script
## Called by the main refresh command for Pantheon platforms

# Colors / divider / emojis come from load-config.sh (sourced below).
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Parse command line arguments
FORCE_BACKUP=false
ENVIRONMENT="${HOSTING_ENV:-dev}"

for arg in "$@"; do
  case $arg in
    --force|-f)
      FORCE_BACKUP=true
      shift
      ;;
    true|false)
      # Allow positional boolean (used by db-prep-migrate).
      [ "$arg" = "true" ] && FORCE_BACKUP=true
      shift
      ;;
    *)
      if [ "$arg" != "2" ] && [ -z "${ENVIRONMENT_SET:-}" ]; then
        ENVIRONMENT="$arg"
        ENVIRONMENT_SET=true
      fi
      shift
      ;;
  esac
done

cd "${DDEV_APPROOT}"

echo -e "\n${yellow} Authenticating with Terminus... ${NC}"
if [ -z "${TERMINUS_MACHINE_TOKEN:-}" ]; then
    echo -e "${red}TERMINUS_MACHINE_TOKEN environment variable is not set in the web container. Please configure it in your global ddev config.${NC}"
    exit 1
fi

if ! terminus auth:login --machine-token="${TERMINUS_MACHINE_TOKEN}"; then
    echo -e "${red}Failed to authenticate with Terminus. Please check your TERMINUS_MACHINE_TOKEN.${NC}"
    exit 1
fi
echo -e "${green}Successfully authenticated with Terminus.${NC}"

echo -e "\n${yellow} Get database from Pantheon environment: ${ENVIRONMENT}. ${NC}"
echo -e "${green}${divider}${NC}"

SITE_NAME="${HOSTING_SITE:-$DDEV_PROJECT}"
SITE_ENV="${SITE_NAME}.${ENVIRONMENT}"

echo -e "\nChecking for database backup on ${SITE_ENV}..."

LATEST_BACKUP_TIMESTAMP=$(terminus backup:list "${SITE_ENV}" --element=database --format=list --field=date 2>/dev/null | head -1)

# Pantheon backup age is checked against the API (not a local file), so the
# shared should_refresh_backup helper doesn't fit — we keep this inline check
# but use the same 12h threshold semantics.
CURRENT_TIME=$(date +%s)
TWELVE_HOURS_AGO=$((CURRENT_TIME - 43200))
CREATE_NEW_BACKUP=false

if [ "$FORCE_BACKUP" = true ]; then
    echo -e "${yellow}Force flag detected. Creating new backup regardless of age.${NC}"
    CREATE_NEW_BACKUP=true
elif [ -z "$LATEST_BACKUP_TIMESTAMP" ]; then
    echo -e "${yellow}No database backup found.${NC}"
    CREATE_NEW_BACKUP=true
else
    BACKUP_TIME=${LATEST_BACKUP_TIMESTAMP%.*}
    BACKUP_AGE_HOURS=$(( (CURRENT_TIME - BACKUP_TIME) / 3600 ))
    if [ "$BACKUP_TIME" -lt "$TWELVE_HOURS_AGO" ]; then
        echo -e "${yellow}Latest backup is ${BACKUP_AGE_HOURS} hours old (older than 12 hours).${NC}"
        CREATE_NEW_BACKUP=true
    else
        echo -e "${green}Recent backup found (${BACKUP_AGE_HOURS} hours old): ${LATEST_BACKUP_TIMESTAMP}${NC}"
    fi
fi

if [ "$CREATE_NEW_BACKUP" = true ]; then
    echo -e "${yellow}Creating new backup for ${SITE_ENV}...${NC}"
    if terminus backup:create "${SITE_ENV}" --element=database -y; then
        echo -e "${green}Backup created successfully.${NC}"
        echo "Waiting for backup to complete..."
        sleep 10
    else
        echo -e "${red}Failed to create backup for ${SITE_ENV}. Exiting.${NC}"
        exit 1
    fi
fi

echo -e "\nDownloading database backup from ${SITE_ENV}..."
DB_DUMP="/tmp/pantheon_backup.${SITE_ENV}.sql.gz"
terminus backup:get "${SITE_ENV}" --element=database --to="${DB_DUMP}"

if [ -n "${DDEV_DOCROOT}" ]; then
    cd "${DDEV_APPROOT}/${DDEV_DOCROOT}"
else
    cd "${DDEV_APPROOT}"
fi

# Shared import + URL rewrite.
finalize_database_import "${DB_DUMP}"

echo -e "${green}${divider}${NC}"
echo -e "${green}Pantheon database refresh complete!${NC}"
echo -e "${green}${divider}${NC}"
