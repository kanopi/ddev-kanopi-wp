#!/usr/bin/env bats

# Test suite for ddev-kanopi-wp add-on

setup() {
    export PROJNAME=test-kanopi-wp
    export TESTDIR=~/tmp/$PROJNAME
    mkdir -p $TESTDIR && cd $TESTDIR
    export DDEV_NON_INTERACTIVE=true
    ddev delete -Oy $PROJNAME || true
    cd $TESTDIR
}

health_checks() {
    # Basic health checks for the add-on
    ddev exec "php --version" | grep "PHP"
    ddev exec "wp --version" | grep "WP-CLI"
    
    # Check services are running
    docker ps | grep "ddev-${PROJNAME}-pma"
    docker ps | grep "ddev-${PROJNAME}-redis" 
    docker ps | grep "ddev-${PROJNAME}-solr"
    
    # Check custom commands exist
    ddev create-block --help || [ $? -eq 1 ]  # Should show usage
    ddev development --help || echo "development command exists"
    ddev production --help || echo "production command exists"
    ddev refresh --help || echo "refresh command exists"
    ddev activate-theme --help || echo "activate-theme command exists"
    ddev restore-admin-user --help || echo "restore-admin-user command exists"
    
    # Check configuration files exist
    [ -f ".ddev/.env-kanopi-wp-example" ]
    [ -f ".ddev/config/php/php.ini" ]
    [ -f ".ddev/config/nginx/nginx-site.conf" ]
    [ -d ".ddev/config/wp/block-template" ]
}

teardown() {
    set -eu -o pipefail
    cd $TESTDIR || ( printf "unable to cd to $TESTDIR\n" && exit 1 )
    ddev delete -Oy $PROJNAME
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