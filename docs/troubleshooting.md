# Troubleshooting

Common issues and solutions for the DDEV Kanopi WordPress add-on.

## Authentication Issues

### Pantheon Authentication

#### Symptoms
- Terminus commands fail with authentication errors
- Database refresh fails to connect to Pantheon

#### Solutions
```bash
# Check if token is set
ddev exec printenv TERMINUS_MACHINE_TOKEN

# Re-authenticate manually
ddev pantheon-terminus auth:login --machine-token="your_token"

# Set token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token_here
ddev restart

# Test authentication
ddev pantheon-terminus auth:whoami
```

### WPEngine Authentication

#### Symptoms
- SSH connections fail
- Database operations timeout or fail

#### Solutions
```bash
# Check SSH access
ddev auth ssh

# Test connection manually
ssh your-install@your-install.ssh.wpengine.net

# Verify SSH key configuration
ddev exec printenv WPENGINE_SSH_KEY

# Add SSH key to agent
ssh-add ~/.ssh/your-wpengine-key
```

### Kinsta Authentication

#### Symptoms
- SSH connection refused
- Database operations fail with connection errors

#### Solutions
```bash
# Check SSH configuration
ddev exec printenv REMOTE_HOST
ddev exec printenv REMOTE_PORT
ddev exec printenv REMOTE_USER

# Test SSH connection
ddev auth ssh
ssh -p $PORT $USER@$HOST

# Verify SSH key in MyKinsta dashboard
# Add SSH key if missing
```

## Database Refresh Issues

### Backup Age Detection Problems

#### Issue: Always creates new backups
```bash
# Force refresh to test
ddev db-refresh -f

# Check provider-specific tools
# Pantheon:
ddev pantheon-terminus backup:list my-site.live

# WPEngine/Kinsta:
# Check SSH connectivity and backup availability
```

#### Issue: Cannot detect backup age
- **Pantheon**: Verify Terminus authentication
- **WPEngine**: Check SSH key and server connectivity
- **Kinsta**: Verify SSH credentials and server access

### Connection Timeouts

#### Solutions
```bash
# Increase timeout for slow connections
# Edit command files to add timeout options

# Test basic connectivity first
ddev auth ssh  # For SSH-based providers

# For Pantheon, test Terminus
ddev pantheon-terminus site:list
```

### Large Database Issues
```bash
# For very large databases, use manual approach
# 1. Create backup manually on hosting provider
# 2. Download to local system
# 3. Import using ddev import-db

# Example for manual import:
ddev import-db < large-database-backup.sql
```

## Theme Development Issues

### Node.js Version Problems

#### Symptoms
- npm install fails
- Build processes error out
- Incompatible package versions

#### Solutions
```bash
# Check Node.js version
ddev exec node --version

# Reinstall Node.js and dependencies
ddev theme-install

# Clear npm cache
ddev theme-npm cache clean --force

# Remove node_modules and reinstall
ddev exec rm -rf /var/www/html/wp-content/themes/[theme]/node_modules
ddev theme-install
```

### Build Process Failures

#### SCSS Compilation Errors
```bash
# Check for syntax errors in SCSS files
ddev theme-npm run build

# Review build output for specific errors
ddev logs

# Clear build cache
ddev exec rm -rf /var/www/html/wp-content/themes/[theme]/assets/dist
ddev theme-build
```

#### JavaScript Build Errors
```bash
# Check for ES6/JSX syntax errors
ddev theme-npm run lint

# Review webpack configuration
# Check package.json for script definitions
ddev theme-npm run build -- --verbose
```

### Asset Loading Issues

#### Symptoms
- Styles not loading in browser
- JavaScript functionality broken
- 404 errors for assets

#### Solutions
```bash
# Check file permissions
ddev exec ls -la wp-content/themes/[theme]/assets/dist/

# Verify enqueue functions in theme
# Ensure proper file paths and URLs

# Clear browser cache
# Hard refresh (Ctrl+F5 or Cmd+Shift+R)

# Check for proper cache busting
# Verify filemtime() usage in enqueue functions
```

## Command Execution Issues

### Command Not Found

#### Issue: Custom commands not available
```bash
# Check if add-on is properly installed
ddev add-on list

# Verify command files exist
ls -la .ddev/commands/web/
ls -la .ddev/commands/host/

# Reinstall add-on if needed
ddev add-on get kanopi/ddev-kanopi-wp
ddev restart
```

### Permission Errors

#### File Permission Issues
```bash
# Fix file permissions in theme directory
ddev exec chown -R www-data:www-data /var/www/html/wp-content/themes/

# Fix script permissions
ddev exec chmod +x .ddev/commands/web/*
ddev exec chmod +x .ddev/commands/host/*
```

### Environment Variable Issues

#### Missing Configuration
```bash
# Check if variables are set
ddev exec printenv | grep -E "(HOSTING|THEME|WP_)"

# Run configuration wizard
ddev project-configure

# Verify configuration files exist
ls -la .ddev/scripts/load-config.sh
cat .ddev/config.yaml | grep -A 20 web_environment
```

## Performance Issues

### Slow Database Operations

#### Large Database Transfers
- Use `-f` flag judiciously to avoid unnecessary backups
- Consider off-peak hours for large refreshes
- Monitor network connectivity

#### SSH Connection Optimization
```bash
# For SSH-based providers (WPEngine, Kinsta)
# Add SSH connection optimization to ~/.ssh/config:

Host *.ssh.wpengine.net
    ControlMaster auto
    ControlPath ~/.ssh/controlmasters/%r@%h:%p
    ControlPersist 10m
```

### Memory Issues

#### Node.js Memory Errors
```bash
# Increase Node.js memory limit
ddev theme-npm run build --max-old-space-size=4096

# Or set environment variable
ddev config --web-environment-add=NODE_OPTIONS=--max-old-space-size=4096
ddev restart
```

#### PHP Memory Limits
```bash
# Check current PHP memory limit
ddev exec php -ini | grep memory_limit

# Increase if needed via .ddev/config.yaml
# php_version: "8.1"
# webimage_extra_packages: [php8.1-dev]
# php_memory_limit: 512M
```

## Network and Connectivity Issues

### VPN Interference

#### Symptoms
- SSH connections fail intermittently
- API calls timeout
- DNS resolution issues

#### Solutions
- Disconnect VPN temporarily for testing
- Configure VPN to allow DDEV traffic
- Use VPN split tunneling for local development

### Firewall Issues

#### Corporate Firewalls
- Ensure SSH (port 22) is allowed
- Allow custom SSH ports (Kinsta uses custom ports)
- Whitelist hosting provider IP ranges

### DNS Issues

#### Local DNS Resolution
```bash
# Flush DNS cache
# macOS:
sudo dscacheutil -flushcache

# Linux:
sudo systemctl flush-dns

# Windows:
ipconfig /flushdns
```

## File and Directory Issues

### Missing Directories

#### Theme Directory Issues
```bash
# Verify theme directory exists
ls -la wp-content/themes/

# Check THEME variable
ddev exec printenv THEME

# Create theme directory if missing
mkdir -p wp-content/themes/your-theme
```

#### Build Directory Issues
```bash
# Create missing asset directories
mkdir -p wp-content/themes/[theme]/assets/dist
mkdir -p wp-content/themes/[theme]/assets/src

# Set proper permissions
ddev exec chown -R www-data:www-data wp-content/themes/[theme]/assets/
```

## Service Integration Issues

### Redis Issues

#### Redis Service Not Available
```bash
# Check service status
ddev describe

# Reinstall Redis if needed
ddev add-on get ddev/ddev-redis
ddev restart
```

## Getting Help

### Debug Information Collection

#### System Information
```bash
# DDEV version and status
ddev version
ddev describe

# Check add-on installation
ddev add-on list

# Environment variables
ddev exec printenv | grep -E "(HOSTING|THEME|WP_|DDEV_)"
```

#### Log Collection
```bash
# DDEV logs
ddev logs

# Command execution logs
# Check command output for specific error messages

# System logs
# Check hosting provider dashboards for additional error information
```

### Community Resources

- **GitHub Issues**: [Report bugs and request features](https://github.com/kanopi/ddev-kanopi-wp/issues)
- **DDEV Community**: [General DDEV support](https://ddev.readthedocs.io/)
- **WordPress Support**: [WordPress-specific issues](https://wordpress.org/support/)

### Professional Support

For complex issues or custom implementations:
- **Kanopi Studios**: [Professional WordPress development](https://kanopi.com)
- **DDEV Support**: [Commercial DDEV support](https://ddev.com/support/)

## Prevention and Best Practices

### Regular Maintenance
1. **Keep add-on updated**: `ddev add-on get kanopi/ddev-kanopi-wp`
2. **Monitor hosting provider changes**: API updates, SSH key rotations
3. **Regular backup testing**: Ensure refresh processes work consistently
4. **Document custom configurations**: Keep team documentation current

### Environment Hygiene
1. **Clean builds**: Regularly clear build caches and node_modules
2. **Fresh environments**: Periodically recreate DDEV environments
3. **Dependency updates**: Keep npm packages and PHP dependencies current
4. **Security updates**: Regular updates for WordPress core and plugins