# Adding DDEV Support to wp-config.php

This guide shows how to add DDEV support to existing wp-config.php environment detection loops, particularly useful for projects migrating from other development environments.

## Pantheon Structure

If your wp-config.php currently has this structure:

1. **Pantheon** - loads `wp-config-pantheon.php`
2. **Local** - loads `wp-config-local.php`
3. **Fallback** - default database settings

## Adding DDEV Support

To add DDEV as a third environment option, modify the configuration section to include DDEV detection:

```php
/**
 * Pantheon platform settings. Everything you need should already be set.
 */
if ( file_exists( dirname( __FILE__ ) . '/wp-config-pantheon.php' ) && isset( $_ENV['PANTHEON_ENVIRONMENT'] ) ) {
    require_once dirname( __FILE__ ) . '/wp-config-pantheon.php';

    /**
     * DDEV local development environment.
     */
} elseif ( file_exists( dirname( __FILE__ ) . '/wp-config-ddev.php' ) && getenv( 'IS_DDEV_PROJECT' ) == 'true' ) {
    require_once dirname( __FILE__ ) . '/wp-config-ddev.php';

    /**
     * Local configuration information.
     *
     * If you are working in a local/desktop development environment and want to
     * keep your config separate, we recommend using a 'wp-config-local.php' file,
     * which you should also make sure you .gitignore.
     */
} elseif ( file_exists( dirname( __FILE__ ) . '/wp-config-local.php' ) && ! isset( $_ENV['PANTHEON_ENVIRONMENT'] ) ) {
    // IMPORTANT: ensure your local config does not include wp-settings.php
    require_once dirname( __FILE__ ) . '/wp-config-local.php';

    /**
     * This block will be executed if you are NOT running on Pantheon, DDEV, and have NO
     * wp-config-local.php. Insert alternate config here if necessary.
     */
} else {
    define( 'DB_NAME', 'database_name' );
    define( 'DB_USER', 'database_username' );
    define( 'DB_PASSWORD', 'database_password' );
    define( 'DB_HOST', 'database_host' );
    define( 'DB_CHARSET', 'utf8' );
    define( 'DB_COLLATE', '' );
    define( 'AUTH_KEY', 'put your unique phrase here' );
    define( 'SECURE_AUTH_KEY', 'put your unique phrase here' );
    define( 'LOGGED_IN_KEY', 'put your unique phrase here' );
    define( 'NONCE_KEY', 'put your unique phrase here' );
    define( 'AUTH_SALT', 'put your unique phrase here' );
    define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
    define( 'LOGGED_IN_SALT', 'put your unique phrase here' );
    define( 'NONCE_SALT', 'put your unique phrase here' );
}
```

## Environment Detection

The DDEV config file uses environment detection (`getenv( 'IS_DDEV_PROJECT' ) == 'true'`) to ensure it only loads in DDEV environments.

## Alternative Simple Configuration

For simpler setups, you can also use this minimal approach in your wp-config.php:

```php
// Include for ddev-managed settings in wp-config-ddev.php.
$ddev_settings = dirname(__FILE__) . '/wp-config-ddev.php';
if (is_readable($ddev_settings) && !defined('DB_USER')) {
  require_once($ddev_settings);
}
```

This approach works well for projects that don't need complex environment detection.