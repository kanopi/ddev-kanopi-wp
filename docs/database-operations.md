# Database Operations

Comprehensive database management with smart refresh capabilities, migration support, and multi-provider compatibility.

## Smart Database Refresh

The enhanced `ddev db-refresh` command includes intelligent backup management across all hosting providers.

### Basic Usage
```bash
# Refresh from default environment
ddev db-refresh

# Refresh from specific environment
ddev db-refresh live

# Force new backup creation
ddev db-refresh -f

# Refresh from staging environment
ddev db-refresh staging
```

### Smart Features

#### Automatic Backup Age Detection
- **12-hour threshold**: Automatically checks if backups are older than 12 hours
- **Provider-specific**: Uses each platform's API/tools for accurate age detection
- **Efficiency**: Avoids unnecessary backup creation

#### Multi-Environment Support
- **Pantheon**: dev, test, live, multidev environments
- **WPEngine**: production, staging environments
- **Kinsta**: production, staging configurations

#### Provider-Agnostic Interface
Unified command interface across all hosting providers:
- Consistent syntax regardless of provider
- Automatic provider detection
- Seamless switching between environments

## Database Rebuild

Comprehensive rebuild process combining dependency management and database refresh:

```bash
# Run composer install followed by database refresh
ddev db-rebuild
```

**Process includes:**
1. Composer dependency installation
2. Database refresh from hosting provider
3. Theme activation
4. Admin user restoration
5. Development environment preparation

## Migration Support

### Preparation for Migrations
```bash
# Create secondary database for migration work
ddev db-prep-migrate
```

This creates a separate database for:
- Testing migration scripts
- Comparing data structures
- Backup purposes during migrations

### Cross-Site Migration (Pantheon)
For Pantheon users, configure migration between different sites:

```bash
# During configuration, set:
# MIGRATE_DB_SOURCE - Source site machine name
# MIGRATE_DB_ENV - Source environment (dev/test/live)
```

## Provider-Specific Database Operations

### Pantheon Database Operations

#### Terminus Integration
```bash
# Direct Terminus commands for database operations
ddev pantheon-terminus backup:create my-site.live --element=db
ddev pantheon-terminus backup:list my-site.live
```

#### Multidev Support
```bash
# Refresh from multidev environment
ddev db-refresh my-feature-branch

# Work with complex multidev workflows
ddev pantheon-testenv feature-test fresh
```

#### Environment Tickling
```bash
# Keep environment awake during long operations
ddev pantheon-tickle
```

### WPEngine Database Operations

#### SSH-Based Operations
- Secure SSH connections for database access
- Utilizes WPEngine's nightly automated backups
- Custom SSH key handling for authentication

#### Backup Strategy
- Leverages WPEngine's backup infrastructure
- SSH-based retrieval for security
- Smart age detection for efficiency

### Kinsta Database Operations

#### Direct SSH Access
- Custom SSH configuration per site
- Direct server database connections
- Flexible path configuration

#### Custom Backup Management
- SSH-based database operations
- Configurable backup retention
- Direct database access for performance

## Database Management Tools

### Command-Line Database Access
```bash
# Access MySQL/MariaDB directly
ddev mysql

# Run SQL commands
ddev mysql -e "SHOW TABLES;"

# Import SQL files
ddev import-db < backup.sql
```

## Post-Refresh Automation

After database refresh, the system automatically:

1. **Search and Replace**: Updates URLs for local development
2. **Theme Activation**: Activates configured theme
3. **Admin User Restoration**: Ensures admin access
4. **Plugin Management**: Deactivates problematic plugins
5. **Cache Clearing**: Clears object and page caches

## Troubleshooting Database Operations

### Connection Issues

#### Pantheon
```bash
# Check Pantheon authentication
ddev pantheon-terminus auth:whoami

# Verify site access
ddev pantheon-terminus site:info my-site
```

#### WPEngine
```bash
# Check SSH configuration
ddev auth ssh

# Test SSH connection
ssh your-install@your-install.ssh.wpengine.net
```

#### Kinsta
```bash
# Verify SSH credentials
ddev exec printenv REMOTE_HOST
ddev exec printenv REMOTE_PORT

# Test SSH connectivity
ssh -p $PORT $USER@$HOST
```

### Backup Issues

#### Force New Backup
```bash
# Force new backup creation regardless of age
ddev db-refresh -f
```

#### Manual Backup Creation
```bash
# Pantheon - create backup manually
ddev pantheon-terminus backup:create my-site.live --element=db

# Check backup status
ddev pantheon-terminus backup:list my-site.live
```

### Performance Optimization

#### Large Database Handling
- Automatic compression during transfer
- Efficient transfer protocols
- Progress indicators for large operations

#### Network Optimization
- Connection pooling where applicable
- Resume capability for interrupted transfers
- Bandwidth optimization

## Best Practices

### Development Workflow
1. **Daily refresh**: `ddev db-refresh` to get latest content
2. **Force refresh**: Use `-f` flag when content changes are critical
3. **Environment-specific**: Refresh from appropriate environment (dev/staging/live)

### Migration Workflows
1. **Prepare secondary DB**: `ddev db-prep-migrate` before major migrations
2. **Test migrations**: Use secondary database for testing
3. **Backup before changes**: Always refresh before major local changes

### Team Collaboration
- Document environment refresh schedules
- Use consistent environment names
- Share migration scripts and procedures

### Performance Considerations
- Schedule large refreshes during off-peak hours
- Use force flag judiciously to avoid unnecessary backup creation
- Monitor backup creation frequency across team members