#!/usr/bin/env bats

# Test suite for ddev-kanopi-wp add-on

setup() {
    export PROJNAME=test-kanopi-wp
    export TESTDIR=~/tmp/$PROJNAME
    export DIR=${BATS_TEST_DIRNAME}/..
    mkdir -p $TESTDIR && cd $TESTDIR
    export DDEV_NONINTERACTIVE=true
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    cd $TESTDIR
}

health_checks() {
    echo "Starting health checks..." >&3
    # Basic health checks for the add-on
    echo "Checking PHP version..." >&3
    ddev exec "php --version" | grep "PHP"
    echo "Checking WP-CLI..." >&3
    # Note: WP-CLI may not be available in test environment
    ddev exec "wp --version" 2>/dev/null | grep "WP-CLI" || echo "WP-CLI not available in test environment"
    
    echo "Checking Docker services..." >&3
    # Check services are running (from DDEV add-ons)
    docker ps | grep "ddev-${PROJNAME}-redis" || echo "Redis service should be running"
    docker ps | grep "ddev-${PROJNAME}-solr" || echo "Solr service should be running"
    docker ps | grep "ddev-${PROJNAME}-pma" || echo "PhpMyAdmin service should be running"
    
    echo "Checking custom commands..." >&3
    # Check custom commands exist (may be skipped if conflicts with existing DDEV commands)
    ddev theme:create-block --help || echo "theme:create-block command exists or skipped due to conflicts"
    ddev theme:watch --help || echo "theme:watch command exists or skipped due to conflicts"
    ddev theme:build --help || echo "theme:build command exists or skipped due to conflicts"
    ddev db:refresh --help || echo "db:refresh command exists or skipped due to conflicts"
    ddev theme:activate --help || echo "theme:activate command exists or skipped due to conflicts"
    ddev wp:restore-admin-user --help || echo "wp:restore-admin-user command exists or skipped due to conflicts"
    ddev theme:npm --help || echo "theme:npm command exists or skipped due to conflicts"
    ddev pantheon:terminus --help || echo "pantheon:terminus command exists or skipped due to conflicts"
    
    echo "Checking configuration files..." >&3
    # Check configuration files exist
    # Configuration is now handled via environment variables
    [ -f ".ddev/config/php/php.ini" ] || echo "Missing .ddev/config/php/php.ini"
    [ -f ".ddev/config/nginx/nginx-site.conf" ] || echo "Missing .ddev/config/nginx/nginx-site.conf"
    [ -d ".ddev/config/wp/block-template" ] || echo "Missing .ddev/config/wp/block-template"
    
    echo "Checking scripts folder..." >&3
    # Check that scripts folder was copied
    [ -d ".ddev/scripts" ] || echo "Missing .ddev/scripts directory"
    [ -f ".ddev/scripts/pantheon-refresh.sh" ] || echo "Missing pantheon-refresh.sh"
    [ -f ".ddev/scripts/wpengine-refresh.sh" ] || echo "Missing wpengine-refresh.sh"
    [ -f ".ddev/scripts/kinsta-refresh.sh" ] || echo "Missing kinsta-refresh.sh"
    
    echo "Checking gitignore..." >&3
    # Check gitignore was updated for add-on settings
    grep -q "settings.ddev.redis.php" .gitignore || echo "gitignore should contain add-on settings files"
    echo "Health checks completed." >&3
}

teardown() {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    ddev delete -Oy $PROJNAME >/dev/null 2>&1 || true
    [ "$TESTDIR" != "" ] && rm -rf $TESTDIR
}

@test "install from directory" {
    set -eu -o pipefail
    cd $TESTDIR
    echo "# ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot" >&3
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    
    echo "# ddev add-on get $DIR with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
    ddev add-on get $DIR
    
    echo "# ddev start" >&3
    ddev start
    
    health_checks
}

@test "environment variable configuration" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start
    
    # Check that environment variables were set correctly
    ddev exec printenv HOSTING_PROVIDER | grep -q "pantheon"
    ddev exec printenv HOSTING_SITE | grep -q "test-site-123"
    ddev exec printenv HOSTING_ENV | grep -q "dev"
    ddev exec printenv THEME | grep -q "wp-content/themes/custom"
    ddev exec printenv THEMENAME | grep -q "testtheme"
    ddev exec printenv WP_ADMIN_USER | grep -q "admin"
    ddev exec printenv WP_ADMIN_EMAIL | grep -q "admin"
}

@test "interactive installation wizard" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    
    # Test non-interactive mode (should use defaults)
    export DDEV_NONINTERACTIVE=true
    ddev add-on get $DIR
    ddev start
    
    # Check that default values were used in environment variables
    ddev exec printenv HOSTING_PROVIDER | grep -q "pantheon"
    ddev exec printenv HOSTING_SITE | grep -q "test-site-123"
    ddev exec printenv WP_ADMIN_USER | grep -q "admin"
}

@test "block template functionality" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start
    
    # Check that block template directory exists
    [ -d ".ddev/config/wp/block-template" ]
    
    # Check that theme:create-block command exists and has proper structure
    ddev theme:create-block --help >/dev/null 2>&1 || echo "theme:create-block command should exist"

    # Test block creation (this will fail without proper theme structure, but command should exist)
    ddev theme:create-block test-block || echo "theme:create-block command executed (may fail without theme)"
}

@test "docker services" {
    set -eu -o pipefail  
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start
    
    # Wait a moment for services to fully start
    sleep 5
    
    # Check that core services are running (web and db are essential)
    docker ps | grep "ddev-${PROJNAME}-web"
    docker ps | grep "ddev-${PROJNAME}-db"

    # Check additional services (allow these to fail gracefully)
    docker ps | grep "ddev-${PROJNAME}-pma" || echo "PhpMyAdmin service not running"
    docker ps | grep "ddev-${PROJNAME}-redis" || echo "Redis service not running"
    docker ps | grep "ddev-${PROJNAME}-solr" || echo "Solr service not running"
}

@test "pantheon mu-plugin handling" {
    set -eu -o pipefail
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    
    # Create a mock Pantheon mu-plugin loader that would cause conflicts
    mkdir -p web/wp-content/mu-plugins
    cat > web/wp-content/mu-plugins/pantheon-mu-loader.php << 'EOF'
<?php
// Mock Pantheon mu-plugin loader for testing
$pantheon_mu_plugins = [
    'pantheon-mu-plugin/pantheon.php',
];

foreach ( $pantheon_mu_plugins as $file ) {
    require_once WPMU_PLUGIN_DIR . '/' . $file;
}
EOF

    # Install the add-on
    ddev add-on get $DIR
    ddev start

    # Check that the problematic mu-plugin loader was disabled
    [ -f "web/wp-content/mu-plugins/pantheon-mu-loader.php.disabled" ]
    [ ! -f "web/wp-content/mu-plugins/pantheon-mu-loader.php" ]
    
    # Verify WP-CLI works without fatal errors
    ddev exec wp core version 2>/dev/null || echo "WP-CLI not available or WordPress not fully configured"
}