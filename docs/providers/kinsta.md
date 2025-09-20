# Kinsta Integration

Direct SSH integration with Kinsta hosting, providing flexible database operations and custom server configurations.

## Configuration

### Required Variables
- `REMOTE_HOST` - SSH host (IP address or hostname)
- `REMOTE_PORT` - SSH port number
- `REMOTE_USER` - SSH username
- `REMOTE_PATH` - Remote path on server (e.g., `/www/somepath/public`)

### Setup Process

1. **Get SSH Credentials**
   - Log into MyKinsta dashboard
   - Navigate to your site's Info tab
   - Note SSH credentials (host, port, username)

2. **Add SSH Key to Kinsta**
   - Go to MyKinsta > User Settings > SSH Keys
   - Add your SSH public key

3. **Project Configuration**
   ```bash
   ddev project-configure
   # Select Kinsta as provider
   # Enter SSH host (IP address)
   # Enter SSH port
   # Enter SSH username
   # Enter remote path to WordPress installation
   ```

## Features

### Flexible SSH Configuration
- **Custom host and port**: Works with Kinsta's unique SSH setup per site
- **Direct server access**: Connect directly to your Kinsta server
- **Path configuration**: Specify exact path to your WordPress installation

### Database Operations
- **SSH-based database access**: Secure remote database operations
- **Custom backup strategies**: Flexible backup creation and retrieval
- **Environment support**: Works with staging and production environments

```bash
# Refresh database from production
ddev db-refresh

# Force new database sync
ddev db-refresh -f
```

## Authentication Setup

### SSH Key Management
```bash
# Add SSH key to Kinsta (via MyKinsta dashboard)
# Then enable SSH agent in DDEV
ddev auth ssh
```

### Connection Testing
```bash
# Test SSH connection manually
ssh -p YOUR_PORT YOUR_USERNAME@YOUR_HOST

# Example:
ssh -p 12345 mysite@123.456.789.10
```

## Configuration Examples

### Typical Kinsta Setup
```bash
# Example configuration values:
REMOTE_HOST=123.456.789.10
REMOTE_PORT=12345
REMOTE_USER=mysite
REMOTE_PATH=/www/mysite_123/public
```

### Path Variations
Kinsta paths typically follow patterns like:
- `/www/sitename_123/public`
- `/www/sitename_456/public_html`
- `/www/custom_path/htdocs`

## Troubleshooting

### SSH Connection Issues
```bash
# Check environment variables
ddev exec printenv REMOTE_HOST
ddev exec printenv REMOTE_PORT
ddev exec printenv REMOTE_USER
ddev exec printenv REMOTE_PATH

# Test SSH agent
ddev auth ssh

# Manual connection test
ssh -p $PORT $USER@$HOST
```

### Common Issues

#### Wrong Port or Host
- Verify credentials in MyKinsta dashboard
- Ensure firewall allows SSH traffic
- Check VPN configurations

#### Path Issues
- Verify remote path points to WordPress root
- Check file permissions on remote server
- Ensure path includes proper directory structure

#### SSH Key Issues
- Confirm key is added to MyKinsta
- Test key locally before using with DDEV
- Verify key format (OpenSSH vs other formats)

## File Structure

### Recommended Docroot
- **Docroot**: `public` (set during `ddev config`)
- **File proxy**: Can be configured for missing assets
- **Local development**: Matches Kinsta's server structure

## Database Management

### Backup Strategy
- Custom backup creation via SSH
- Direct database access for efficiency
- Configurable backup retention

### Performance Considerations
- Direct SSH connections for speed
- Efficient database transfer methods
- Optimized for Kinsta's infrastructure

## Best Practices

### SSH Security
- Use strong SSH key passphrases
- Regularly rotate SSH keys
- Monitor access via MyKinsta dashboard

### Development Workflow
```bash
# Initialize environment
ddev project-init

# Sync latest database
ddev db-refresh

# Start development
ddev theme-watch

# Build for production
ddev theme-build
```

### Team Collaboration
- Document SSH credentials securely
- Use shared SSH keys when appropriate
- Maintain consistent path configurations

## Advanced Configuration

### Custom SSH Options
For complex SSH setups, you can modify the SSH commands in the add-on's command files to include additional SSH options:

- Custom identity files
- Proxy jump configurations
- Connection multiplexing
- Timeout settings

### Multi-Environment Support
Configure different Kinsta environments by using different variable sets or modifying the remote path for staging vs production environments.