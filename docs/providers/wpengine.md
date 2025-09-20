# WPEngine Integration

SSH-based integration with WPEngine hosting, including specialized key handling and automated backup retrieval.

## Configuration

### Required Variables
- `HOSTING_SITE` - WPEngine install name
- `WPENGINE_SSH_KEY` - Path to SSH private key for WPEngine access

### Setup Process

1. **SSH Key Management**
   WPEngine allows only one SSH key per account, so proper key management is crucial.

2. **Add SSH Key to WPEngine**
   - Log into WPEngine User Portal
   - Navigate to SSH Keys section
   - Add your SSH public key

3. **Project Configuration**
   ```bash
   ddev project-configure
   # Select WPEngine as provider
   # Enter install name
   # Specify SSH private key path
   ```

## Features

### Database Operations
- **SSH-based backup retrieval**: Uses secure SSH connections
- **Nightly backup utilization**: Leverages WPEngine's automated backups
- **Environment support**: Works with staging and production environments

```bash
# Refresh database from production
ddev db-refresh

# Force new backup creation
ddev db-refresh -f
```

### SSH Key Authentication
The add-on handles WPEngine's specific SSH key requirements:

- Automatic SSH agent integration
- Secure key path configuration
- Connection testing and validation

## Authentication Setup

### SSH Key Configuration
```bash
# The add-on uses the SSH key specified during configuration
# Ensure your key is properly configured:
ssh-add ~/.ssh/your-wpengine-key

# Test connection
ssh your-install@your-install.ssh.wpengine.net
```

### Troubleshooting Authentication
```bash
# Check SSH agent
ddev auth ssh

# Test connection manually
ssh -i ~/.ssh/your-wpengine-key your-install@your-install.ssh.wpengine.net

# Verify configuration
ddev exec printenv WPENGINE_SSH_KEY
```

## File Structure

### Recommended Docroot
- **Docroot**: `public` or `web` (configure during `ddev config`)
- **File proxy**: Configured for missing assets
- **Local development**: Seamless integration with WPEngine file structure

## Database Management

### Backup Strategy
- Utilizes WPEngine's nightly automated backups
- SSH-based retrieval for security
- Smart age detection for efficiency

### Environment Support
```bash
# Production environment (default)
ddev db-refresh

# Staging environment (if configured)
ddev db-refresh staging
```

## Limitations and Considerations

### SSH Key Limitation
- WPEngine allows only **one SSH key per account**
- Ensure the configured key has proper access
- Team workflows may require shared key management

### Network Considerations
- SSH connections require stable internet
- VPN configurations may affect connectivity
- Firewall rules should allow SSH traffic

## Best Practices

### Key Management
- Use dedicated SSH keys for WPEngine
- Store keys securely and backup appropriately
- Document key locations for team members

### Development Workflow
```bash
# Daily workflow
ddev project-init
ddev db-refresh
ddev theme-watch

# Testing workflow
ddev theme-build
# Deploy via WPEngine tools
```

### Security
- Regularly rotate SSH keys
- Use strong key passphrases
- Monitor SSH access logs in WPEngine dashboard