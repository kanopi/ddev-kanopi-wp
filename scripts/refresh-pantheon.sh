#!/usr/bin/env bash
#ddev-generated

## Pantheon Database Refresh Script
## Called by the main refresh command for Pantheon platforms

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
NC='\033[0m'
divider='===================================================\n'

DOCROOT_PATH="${DDEV_APPROOT=}/${DDEV_DOCROOT}"

# Parse command line arguments
FORCE_BACKUP=false
# Get hostingenv from environment, default to 'dev' if not set
ENVIRONMENT="$PANTHEON_ENV"
if [ -z "$ENVIRONMENT" ]; then
  ENVIRONMENT="dev"
fi

for arg in "$@"; do
  case $arg in
    --force|-f)
      FORCE_BACKUP=true
      shift
      ;;
    *)
      # Skip DDEV internal parameters (like "2") and set environment if valid
      if [ "$arg" != "2" ] && [ -z "$ENVIRONMENT_SET" ]; then
        ENVIRONMENT="$arg"
        ENVIRONMENT_SET=true
      fi
      shift
      ;;
  esac
done

cd ${DDEV_APPROOT}

# Ensure terminus authentication before any terminus operations
echo -e "\n${yellow} Authenticating with Terminus... ${NC}"
# Get TERMINUS_MACHINE_TOKEN from environment
TERMINUS_MACHINE_TOKEN=$(printenv TERMINUS_MACHINE_TOKEN 2>/dev/null)
if [ -z "${TERMINUS_MACHINE_TOKEN:-}" ]; then
  echo -e "${red}TERMINUS_MACHINE_TOKEN environment variable is not set in the web container. Please configure it in your global ddev config.${NC}"
  exit 1
fi

# Authenticate with terminus using the machine token
if ! terminus auth:login --machine-token="${TERMINUS_MACHINE_TOKEN}"; then
  echo -e "${red}Failed to authenticate with Terminus. Please check your TERMINUS_MACHINE_TOKEN.${NC}"
  exit 1
fi
echo -e "${green}Successfully authenticated with Terminus.${NC}"


echo -e "\n${yellow} Get database from Pantheon environment: ${ENVIRONMENT}. ${NC}"
echo -e "${green}${divider}${NC}"
# Extract site name from HOSTING_ENV environment variable or fall back to DDEV project name.
SITE_NAME="${HOSTING_ENV:-$DDEV_PROJECT}"

# Set the site environment for backup operations.
if [ "$ENVIRONMENT" != "dev" ]; then
  SITE_ENV="${SITE_NAME}.${ENVIRONMENT}"
  PULL_ENV_FLAG="--environment=project=${SITE_NAME}.${ENVIRONMENT}"
else
  SITE_ENV="${SITE_NAME}.dev"
  PULL_ENV_FLAG=""
fi

echo -e "\nChecking for database backup on ${SITE_ENV}..."

# Check if there's a database backup and get its timestamp.
LATEST_BACKUP_TIMESTAMP=$(terminus backup:list ${SITE_ENV} --element=database --format=list --field=date 2>/dev/null | head -1)

# Calculate current time and 12-hour threshold.
CURRENT_TIME=$(date +%s)
TWELVE_HOURS_AGO=$((CURRENT_TIME - 43200))  # 12 hours = 43200 seconds

CREATE_NEW_BACKUP=false

# Check if force flag is set
if [ "$FORCE_BACKUP" = true ]; then
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

# Now download the database backup using terminus
echo -e "\nDownloading database backup from ${SITE_ENV}..."
DB_DUMP="/tmp/pantheon_backup.${SITE_ENV}.sql.gz"
terminus backup:get ${SITE_ENV} --element=database --to=${DB_DUMP}

echo -e "\nReset DB"
# Stay in DDEV_APPROOT if DDEV_DOCROOT is empty (root-level WordPress)
if [ -n "${DDEV_DOCROOT}" ]; then
  cd ${DDEV_APPROOT}/${DDEV_DOCROOT}
else
  cd ${DDEV_APPROOT}
fi
wp db reset --yes --skip-plugins --skip-themes

echo -e "\nImport db"
gunzip -c $DB_DUMP | sed 's/DEFINER=`[^`]*`@`[^`]*`//g' | wp db import -

## Update urls in main tables
MYSQL_CONNECTION_DETAILS="-h db -pdb -u db db"
OPTIONHOME=$(mysql $MYSQL_CONNECTION_DETAILS -N -B -e "SELECT option_value FROM wp_options WHERE option_name='home';")
echo -e "\nUpdating ${OPTIONHOME} to ${DDEV_PRIMARY_URL}"
wp search-replace "$OPTIONHOME" "$DDEV_PRIMARY_URL" --skip-columns=guid

echo -e "${green}${divider}${NC}"
echo -e "${green}Pantheon database refresh complete!${NC}"
echo -e "${green}${divider}${NC}"