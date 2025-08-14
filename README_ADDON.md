# ddev-kanopi-wp Development and Technical Details

## Add-on Architecture

This DDEV add-on converts Kanopi's Docksal-based WordPress development workflow to DDEV. It provides:

### Services
- **PhpMyAdmin**: Database management interface
- **Redis**: Object caching for WordPress performance
- **Solr**: Search indexing compatible with Pantheon's Solr configuration

### Custom Commands
- **Block Development**: `ddev create-block` for scaffolding new WordPress blocks
- **Asset Compilation**: `ddev development` and `ddev production` for webpack builds
- **Database Management**: `ddev refresh` for Pantheon integration
- **WordPress Setup**: `ddev activate-theme` and `ddev restore-admin-user`
- **Code Quality**: `ddev phpcs` and `ddev phpcbf` for PHP standards
- **Development Tools**: `ddev npm` and `ddev terminus` wrapper commands

### Configuration Files
- **PHP Configuration**: Custom `php.ini` with WordPress-optimized settings
- **NGINX Configuration**: Image proxy and performance optimizations
- **Block Templates**: Complete WordPress block scaffolding system

## File Structure

```
ddev-kanopi-wp/
├── install.yaml                           # DDEV add-on configuration
├── docker-compose.kanopi-wp.yaml         # Services definition
├── commands/
│   ├── web/                               # Commands run inside web container
│   │   ├── create-block                   # Block creation tool
│   │   ├── development                    # Development server
│   │   ├── production                     # Production build
│   │   ├── refresh                        # Pantheon database sync
│   │   ├── activate-theme                 # Theme activation
│   │   ├── restore-admin-user             # Admin user management
│   │   └── open                           # Browser shortcuts
│   └── host/                              # Commands run on host
│       ├── phpcs                          # Code standards check
│       ├── phpcbf                         # Code standards fix
│       ├── npm                            # npm wrapper command
│       └── terminus                       # Terminus wrapper command
├── config/
│   ├── php/php.ini                        # PHP configuration
│   ├── nginx/nginx-site.conf              # NGINX customizations
│   └── wp/block-template/                 # WordPress block templates
│       ├── block.json
│       ├── index.js
│       ├── edit.js
│       ├── save.js
│       ├── style.scss
│       ├── editor.scss
│       └── view.js
├── .env-kanopi-wp-example                 # Environment variables template
└── tests/test.bats                        # Test suite
```

## Docksal to DDEV Conversion Notes

### Command Mapping
| Docksal | DDEV | Notes |
|---------|------|-------|
| `fin init` | `ddev start` + manual setup | DDEV doesn't have an equivalent init command |
| `fin create-block` | `ddev create-block` | Direct port with path adjustments |
| `fin development` | `ddev development` | Runs npm start in theme directory |
| `fin refresh` | `ddev refresh` | Pantheon integration via Terminus |
| `fin npm` | `ddev npm` | Smart wrapper that runs in theme directory |
| `fin terminus` | `ddev terminus` | Wrapper with auto-authentication |

### Service Differences
- **Database**: DDEV uses MariaDB by default vs Docksal's MySQL
- **Web Server**: Both use NGINX but with different configuration approaches
- **CLI Container**: DDEV's web container vs Docksal's separate CLI container

### Environment Variables
Docksal's `.docksal/docksal.env` becomes DDEV's `.ddev/.env-kanopi-wp` with DDEV-specific variable names where needed.

## Development

### Testing
Run the test suite:
```bash
cd tests
bats test.bats
```

### Adding New Commands
1. Create the command file in `commands/web/` or `commands/host/`
2. Make it executable: `chmod +x commands/web/my-command`
3. Add `#ddev-generated` comment at the top
4. Update `install.yaml` to include the new file
5. Add tests in `tests/test.bats`

### Updating Services
1. Modify `docker-compose.kanopi-wp.yaml`
2. Update any related configuration files in `config/`
3. Test with `ddev restart`

## Compatibility

- **DDEV Version**: Requires DDEV >= 1.24.3
- **WordPress**: Compatible with WordPress 5.8+ (block.json support)
- **PHP**: Supports PHP 8.1+ (configurable)
- **Node.js**: Requires Node.js 18+ for webpack builds

## Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `WP_ADMIN_USER` | Admin username | `kadmin` |
| `WP_ADMIN_PASS` | Admin password | `kadmin` |
| `WP_ADMIN_EMAIL` | Admin email | `wordpress@kanopi.com` |
| `WP_THEME_SLUG` | Theme directory name | `struts` |
| `WP_THEME_RELATIVE_PATH` | Path to theme from docroot | `wp-content/themes/custom/struts` |
| `PANTHEON_SITE` | Pantheon site name | (required) |
| `PANTHEON_ENV` | Pantheon environment | `dev` |
| `PANTHEON_TOKEN` | Pantheon machine token | (optional) |
| `ACF_CLIENT_USER` | ACF Pro license key | (required for ACF) |
| `GF_CLIENT_USER` | Gravity Forms license key | (required for GF) |

## Troubleshooting

### Common Issues

1. **Block creation fails**: Ensure theme directory exists and has proper structure
2. **Pantheon refresh fails**: Check `PANTHEON_SITE` and `PANTHEON_TOKEN` configuration
3. **Assets not compiling**: Verify Node.js version and npm dependencies
4. **Redis connection issues**: Restart DDEV services with `ddev restart`

### Debug Commands
```bash
# Check service status
ddev describe

# View service logs
ddev logs -s redis
ddev logs -s solr
ddev logs -s pma

# Check environment variables
ddev exec env | grep WP_

# Test database connection
ddev exec wp db check
```