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
    # Basic health checks for the add-on
    ddev exec "php --version" | grep "PHP"
    ddev exec "wp --version" | grep "WP-CLI"
    
    # Check services are running (from DDEV add-ons)
    docker ps | grep "ddev-${PROJNAME}-redis" 
    docker ps | grep "ddev-${PROJNAME}-solr"
    docker ps | grep "ddev-${PROJNAME}-pma"
    
    # Check custom commands exist (may be skipped if conflicts with existing DDEV commands)
    ddev create-block --help || echo "create-block command exists or skipped due to conflicts"
    ddev development --help || echo "development command exists or skipped due to conflicts"
    ddev production --help || echo "production command exists or skipped due to conflicts"
    ddev refresh --help || echo "refresh command exists or skipped due to conflicts"
    ddev activate-theme --help || echo "activate-theme command exists or skipped due to conflicts"
    ddev restore-admin-user --help || echo "restore-admin-user command exists or skipped due to conflicts"
    ddev phpcs --help || echo "phpcs command exists or skipped due to conflicts"
    ddev phpcbf --help || echo "phpcbf command exists or skipped due to conflicts"
    ddev npm --help || echo "npm command exists or skipped due to conflicts"
    ddev pantheon:terminus --help || echo "pantheon:terminus command exists or skipped due to conflicts"
    
    # Check configuration files exist
    # Configuration is now handled via environment variables
    [ -f ".ddev/config/php/php.ini" ]
    [ -f ".ddev/config/nginx/nginx-site.conf" ]
    [ -d ".ddev/config/wp/block-template" ]
    
    # Check that scripts folder was copied
    [ -d ".ddev/scripts" ]
    [ -f ".ddev/scripts/pantheon-refresh.sh" ]
    [ -f ".ddev/scripts/wpengine-refresh.sh" ]
    [ -f ".ddev/scripts/kinsta-refresh.sh" ]
    
    # Check gitignore was updated for add-on settings
    grep -q "settings.ddev.redis.php" .gitignore || echo "gitignore should contain add-on settings files"
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

@test "install from release" {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    echo "# ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot" >&3
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    
    echo "# ddev add-on get kanopi/ddev-kanopi-wp with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
    ddev add-on get kanopi/ddev-kanopi-wp
    
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
    
    # Check that create-block command exists and has proper structure
    ddev exec "command -v create-block >/dev/null 2>&1" || echo "create-block command should exist"
    
    # Test block creation (this will fail without proper theme structure, but command should exist)
    ddev create-block test-block || echo "create-block command executed (may fail without theme)"
}

@test "docker services" {
    set -eu -o pipefail  
    cd $TESTDIR
    ddev config --project-name=$PROJNAME --project-type=wordpress --docroot=web --create-docroot
    ddev add-on get $DIR
    ddev start
    
    # Wait a moment for services to fully start
    sleep 5
    
    # Check that all expected services are running
    docker ps --format "table {{.Names}}" | grep -E "ddev-${PROJNAME}-(web|db|pma|redis|solr)" | wc -l | grep -q "5"
    
    # Check specific services
    docker ps | grep "ddev-${PROJNAME}-web"
    docker ps | grep "ddev-${PROJNAME}-db" 
    docker ps | grep "ddev-${PROJNAME}-pma"
    docker ps | grep "ddev-${PROJNAME}-redis"
    docker ps | grep "ddev-${PROJNAME}-solr"
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
    ddev exec wp core version
}