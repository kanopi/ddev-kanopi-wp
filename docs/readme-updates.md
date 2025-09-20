# README Updates

After adding the ddev-kanopi-wp DDEV add-on to your project, use this comprehensive prompt to update your project's README with complete DDEV documentation.

## Update Prompt

Use this prompt with your AI assistant to automatically update your project's README:

```
I've added the ddev-kanopi-wp DDEV add-on to this project. Please comprehensively update the README.md to:

1. Add DDEV as the primary setup option before Docksal (mark as 'Recommended')
2. Include complete DDEV command reference - scan all .ddev/commands/ directories (host, web, solr, redis, etc.)
   and document ALL available commands with accurate descriptions organized by category
3. Update asset compilation instructions to show both DDEV and Docksal commands
4. Add DDEV-specific notes in the Important Notes section about virtual host naming
5. Keep existing Docksal instructions as 'Option 2' for backward compatibility

The ddev-kanopi-wp add-on provides WordPress-specific commands for theme development, database operations, hosting
provider integration (Pantheon/WPEngine/Kinsta), performance optimization, and testing. Make sure to capture all
command categories and their specific functionality rather than just the basic DDEV commands.
```

## README Structure Recommendations

### 1. Development Environment Options

Update your README to show DDEV as the primary option:

```markdown
## Local Development Setup

### Option 1: DDEV (Recommended)

DDEV provides a comprehensive WordPress development environment with built-in hosting provider integration.

#### Prerequisites
- [Install DDEV](https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/)
- Hosting provider authentication (Pantheon token, SSH keys, etc.)

#### Setup
\`\`\`bash
# Initialize DDEV (first time only)
ddev config --project-type=wordpress --docroot=public

# Install the Kanopi WordPress add-on
ddev add-on get kanopi/ddev-kanopi-wp

# Configure your hosting provider
ddev project-configure

# Complete project initialization
ddev project-init
\`\`\`

### Option 2: Docksal (Legacy)

Existing Docksal setup instructions...
```

### 2. Command Reference Section

Include a comprehensive command reference organized by category:

```markdown
## Available Commands

### Project Initialization
- `ddev project-init` - Complete development environment setup
- `ddev project-configure` - Interactive configuration wizard
- `ddev project-auth` - Set up hosting provider authentication

### Database Operations
- `ddev db-refresh [env] [-f]` - Smart database refresh with backup detection
- `ddev db-rebuild` - Composer install + database refresh
- `ddev db-prep-migrate` - Prepare secondary database for migrations

### Theme Development
- `ddev theme-install` - Set up Node.js and build tools
- `ddev theme-watch` - Development server with file watching
- `ddev theme-build` - Production asset compilation
- `ddev theme-create-block <name>` - Generate WordPress blocks

### Testing & Quality
- `ddev cypress-install` - Set up Cypress E2E testing
- `ddev cypress-run <command>` - Execute Cypress tests
- `ddev critical-install` - Set up Critical CSS tools
- `ddev critical-run` - Generate Critical CSS

### Hosting Provider Integration
- `ddev pantheon-terminus <command>` - Pantheon Terminus commands
- `ddev wp-open [admin]` - Open site or admin in browser
- `ddev phpmyadmin` - Database management interface

[Complete command list with descriptions and examples]
```

### 3. Asset Compilation Updates

Show both DDEV and Docksal commands:

```markdown
## Asset Compilation

### DDEV (Recommended)
\`\`\`bash
# Install theme dependencies
ddev theme-install

# Development with file watching
ddev theme-watch

# Production build
ddev theme-build

# Custom npm commands
ddev theme-npm run custom-script
\`\`\`

### Docksal (Legacy)
\`\`\`bash
# Legacy Docksal commands
fin npm install
fin npm run dev
fin npm run build
\`\`\`
```

### 4. Virtual Host Information

Add DDEV-specific notes about virtual hosts:

```markdown
## Important Notes

### DDEV Virtual Hosts
- **Primary URL**: `https://projectname.ddev.site`
- **Admin URL**: `https://projectname.ddev.site/wp-admin`
- **PhpMyAdmin**: `https://projectname.ddev.site:8037`
- **Custom ports**: Mail capture on port 8026

Access your site using:
\`\`\`bash
# Open site in browser
ddev wp-open

# Open admin dashboard
ddev wp-open admin
\`\`\`
```

### 5. Hosting Provider Configuration

Document provider-specific setup:

```markdown
## Hosting Provider Setup

### Pantheon
\`\`\`bash
# Set machine token globally
ddev config global --web-environment-add=TERMINUS_MACHINE_TOKEN=your_token

# Configure during project setup
ddev project-configure
# Select Pantheon, enter site name and environment
\`\`\`

### WPEngine
\`\`\`bash
# Add SSH key to WPEngine User Portal first
# Then configure
ddev project-configure
# Select WPEngine, enter install name and SSH key path
\`\`\`

### Kinsta
\`\`\`bash
# Add SSH key to MyKinsta dashboard first
ddev auth ssh

# Configure connection details
ddev project-configure
# Select Kinsta, enter SSH host, port, user, and path
\`\`\`
```

## Common README Sections to Update

### Prerequisites Section
```markdown
## Prerequisites

### DDEV Requirements
- [DDEV installed](https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/)
- Docker Desktop (macOS/Windows) or Docker Engine (Linux)
- Hosting provider authentication:
  - **Pantheon**: Machine token from dashboard
  - **WPEngine**: SSH key added to User Portal
  - **Kinsta**: SSH key added to MyKinsta settings

### Legacy Docksal Requirements
[Existing Docksal prerequisites]
```

### Getting Started Section
```markdown
## Getting Started

### DDEV Setup (Recommended)
1. **Clone the repository**
   \`\`\`bash
   git clone [repository-url]
   cd [project-name]
   \`\`\`

2. **Initialize DDEV**
   \`\`\`bash
   ddev config --project-type=wordpress --docroot=public
   ddev add-on get kanopi/ddev-kanopi-wp
   \`\`\`

3. **Configure hosting provider**
   \`\`\`bash
   ddev project-configure
   \`\`\`

4. **Start development environment**
   \`\`\`bash
   ddev project-init
   \`\`\`

5. **Open your site**
   \`\`\`bash
   ddev wp-open
   \`\`\`
```

### Development Workflow Section
```markdown
## Daily Development Workflow

### DDEV Commands
\`\`\`bash
# Start your day
ddev start
ddev db-refresh              # Get latest database
ddev theme-watch            # Start asset compilation

# During development
ddev wp-open                # Open site
ddev wp-open admin          # Open admin
ddev phpmyadmin            # Database management

# Before committing
ddev theme-build           # Build production assets
ddev cypress-run run       # Run tests
\`\`\`

### Legacy Docksal Commands
[Existing workflow commands]
```

## Advanced README Features

### Command Aliases Table
Include a table showing command aliases:

```markdown
## Command Quick Reference

| Full Command | Short Alias | Description |
|-------------|-------------|-------------|
| `ddev project-init` | `ddev init` | Complete project setup |
| `ddev db-refresh` | `ddev refresh` | Database refresh |
| `ddev theme-watch` | `ddev thw` | Start development server |
| `ddev theme-build` | `ddev thb` | Build production assets |
```

### Service Integration
Document additional services:

```markdown
## Integrated Services

- **PhpMyAdmin**: Database management interface
- **Redis**: Object caching (auto-configured)
- **Solr**: Search integration (if configured)
- **Mail Capture**: Development email testing
```

### Environment Variables
Document important environment variables:

```markdown
## Configuration

Key environment variables set by the add-on:
- `HOSTING_PROVIDER` - Your hosting platform (pantheon/wpengine/kinsta)
- `HOSTING_SITE` - Site identifier on hosting platform
- `THEME` - Path to custom theme directory
- `WP_ADMIN_USER` - WordPress admin username

View all variables: `ddev exec printenv`
```

## Implementation Tips

1. **Preserve existing content**: Keep existing Docksal instructions as "Option 2"
2. **Update systematically**: Go through each section of your current README
3. **Test instructions**: Verify all commands work as documented
4. **Include screenshots**: Add visual guides where helpful
5. **Link to documentation**: Reference the add-on's full documentation
6. **Keep it concise**: Focus on most common development tasks

## Example Complete Section

```markdown
## Development Environment

### DDEV Setup (Recommended)

This project uses the [ddev-kanopi-wp](https://github.com/kanopi/ddev-kanopi-wp) add-on for comprehensive WordPress development.

#### Quick Start
\`\`\`bash
# Clone and setup
git clone [repo-url] && cd [project-name]
ddev config --project-type=wordpress --docroot=public
ddev add-on get kanopi/ddev-kanopi-wp
ddev project-configure  # Follow prompts for your hosting provider
ddev project-init       # Complete setup with database refresh

# Start development
ddev theme-watch        # Asset compilation with file watching
ddev wp-open           # Open site in browser
\`\`\`

#### Available Commands
[Include command reference table]

#### Daily Workflow
[Include common development commands]

### Docksal Setup (Legacy)
[Existing Docksal instructions preserved]
```

This approach ensures your project README provides comprehensive guidance for new developers while maintaining backward compatibility with existing workflows.