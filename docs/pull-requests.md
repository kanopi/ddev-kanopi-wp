# Creating Pull Requests

After you add and configure this add-on to your project, use this comprehensive prompt to create thorough pull requests that document all changes and validation steps.

## Pull Request Creation Prompt

Use this prompt with your AI assistant to create comprehensive pull requests:

```
I need to create a pull request for adding the ddev-kanopi-wp add-on to this WordPress project. Please:

1. Analyze the current setup - Review existing local development environment (Docksal, etc.), hosting provider
   configuration, project structure, and determine if DDEV addon is already present
2. Create a comprehensive PR description following this structure:
   - Project context and motivation for DDEV addition
   - Detailed acceptance criteria covering all functionality
   - Step-by-step validation instructions (adjusted based on current state)
   - Assumptions about SSH keys, licenses, and hosting setup
   - Affected URLs (update domain as appropriate)
   - Deploy notes and dependencies
3. Use these variables appropriately:
   - Hosting Provider: [Detect from config - Pantheon/Kinsta/WPEngine]
   - Project Domain: [Extract from DDEV config or README]
   - Existing Dev Environment: [Docksal/other - maintain compatibility]
   - Premium Plugins: [List any requiring license keys]
   - Addon Status: [Check if already included in PR via .ddev/addon-metadata/]
4. Adjust validation steps based on PR state:
   - If addon is already in PR: Skip installation, note it's included
   - If configuration is already done: Skip ddev configure, note it's pre-configured
   - If addon needs installation: Include ddev add-on get kanopi/ddev-kanopi-wp
   - Always consolidate to simplest workflow (avoid redundant ddev start before ddev init)
5. Include all DDEV-specific elements:
   - Custom commands available (theme, database, hosting integration)
   - Service integrations (PhpMyAdmin, Redis, Solr as configured)
   - Development workflow improvements
   - Multi-environment support details
6. Create the actual PR with proper git commands:
   - Analyze current changes with git status/diff
   - Create descriptive commit message
   - Generate the PR using gh cli with the complete description

Key Validation Flow Patterns:
- If addon is in PR: Skip to token setup → ddev init → testing
- If addon needs installation: Install addon → token setup → ddev init → testing
- If already configured: Skip to ddev init → testing
- Always: Streamline to avoid redundant commands

Make sure to highlight that this is additive (preserves existing workflows) and requires proper SSH/license
configuration.
```

## Pull Request Template

Here's a comprehensive template for your pull request descriptions:

### Title Format
```
Add DDEV development environment with Kanopi WordPress add-on
```

### Description Template

```markdown
## Summary

This PR adds DDEV as the primary local development environment using the [ddev-kanopi-wp](https://github.com/kanopi/ddev-kanopi-wp) add-on. This provides comprehensive WordPress development tooling with direct integration to [Pantheon/WPEngine/Kinsta].

### Motivation
- **Standardized Development**: Consistent development environment across team
- **Hosting Integration**: Direct database refresh and deployment tools
- **Modern Tooling**: Asset compilation, testing framework, and performance optimization
- **Team Efficiency**: Simplified onboarding and automated workflows

## Changes Made

### DDEV Configuration
- [x] Added `.ddev/config.yaml` with WordPress project configuration
- [x] Installed `kanopi/ddev-kanopi-wp` add-on with 26+ custom commands
- [x] Configured [hosting provider] integration with environment variables
- [x] Set up asset compilation workflow with `@wordpress/scripts`

### Development Workflow Enhancements
- [x] Database refresh with smart backup detection: `ddev db-refresh`
- [x] Theme development with file watching: `ddev theme-watch`
- [x] Block creation tooling: `ddev theme-create-block`
- [x] E2E testing with Cypress: `ddev cypress-install`
- [x] Critical CSS generation: `ddev critical-install`

### Service Integration
- [x] PhpMyAdmin for database management
- [x] Redis for object caching (auto-configured)
- [ ] Solr for search (if applicable)

### Documentation Updates
- [x] Updated README.md with DDEV as primary setup option
- [x] Added comprehensive command reference
- [x] Preserved existing Docksal instructions for backward compatibility
- [x] Added troubleshooting guide

## Acceptance Criteria

### ✅ Environment Setup
- [ ] DDEV initializes successfully with WordPress configuration
- [ ] Add-on installs without errors
- [ ] Configuration wizard completes successfully
- [ ] All custom commands are available

### ✅ Hosting Provider Integration
- [ ] [Provider] authentication configured (SSH keys/tokens)
- [ ] Database refresh works from [environment] environment
- [ ] Smart backup detection functions correctly
- [ ] Environment switching works (dev/staging/live)

### ✅ Theme Development
- [ ] Node.js and build tools install correctly
- [ ] Asset compilation works (`ddev theme-build`)
- [ ] File watching functions during development (`ddev theme-watch`)
- [ ] Block creation generates proper scaffolding

### ✅ Service Access
- [ ] WordPress site accessible at `https://[project-name].ddev.site`
- [ ] Admin accessible via `ddev wp-open admin`
- [ ] PhpMyAdmin accessible via `ddev phpmyadmin`
- [ ] Redis integration functioning

### ✅ Testing Integration
- [ ] Cypress installs and runs successfully
- [ ] Test user creation works (`ddev cypress-users`)
- [ ] Critical CSS generation functions

## Validation Instructions

### Prerequisites
**Note**: These steps assume you have the necessary authentication configured:
- **[Pantheon]**: Machine token set globally
- **[WPEngine]**: SSH key added to User Portal
- **[Kinsta]**: SSH key added to MyKinsta dashboard
- **Premium Plugins**: `auth.json` file in project root (if applicable)

### Step 1: Environment Setup
```bash
# Clone the PR branch
git checkout [pr-branch-name]

# [If addon not yet in PR: ddev add-on get kanopi/ddev-kanopi-wp]
# [If not configured: ddev project-configure]

# Initialize complete development environment
ddev project-init

# Expected: DDEV starts, dependencies install, database refreshes, admin user created
```

### Step 2: Verify Core Functionality
```bash
# Test site access
ddev wp-open
# Expected: WordPress site loads at https://[project-name].ddev.site

# Test admin access
ddev wp-open admin
# Expected: WordPress admin loads with configured credentials

# Test database management
ddev phpmyadmin
# Expected: PhpMyAdmin interface accessible
```

### Step 3: Theme Development Validation
```bash
# Test theme tooling setup
ddev theme-install
# Expected: Node.js, npm dependencies install successfully

# Test development server
ddev theme-watch
# Expected: Webpack dev server starts, assets compile with file watching

# Test production build (in new terminal)
ddev theme-build
# Expected: Production assets generated in theme/assets/dist/
```

### Step 4: Database Operations
```bash
# Test database refresh
ddev db-refresh
# Expected: Checks backup age, refreshes if needed, activates theme

# Test force refresh
ddev db-refresh -f
# Expected: Creates new backup, imports fresh database

# Test environment-specific refresh
ddev db-refresh [staging/live]
# Expected: Pulls from specified environment
```

### Step 5: Advanced Features
```bash
# Test block creation
ddev theme-create-block test-block
# Expected: Block scaffolding created in theme/assets/src/blocks/

# Test Cypress setup
ddev cypress-install
ddev cypress-users
# Expected: Cypress installs, test user created

# Test Critical CSS (if applicable)
ddev critical-install
ddev critical-run
# Expected: Critical CSS tools install and generate output
```

### Step 6: Hosting Provider Integration
```bash
# Test provider-specific commands
# Pantheon:
ddev pantheon-terminus site:list
# Expected: Lists Pantheon sites

# WPEngine/Kinsta:
ddev auth ssh
# Expected: SSH agent configured for provider access
```

## Assumptions

### Authentication Setup
- **[Pantheon]**: `TERMINUS_MACHINE_TOKEN` configured globally
- **[WPEngine]**: SSH key added to User Portal, path specified during config
- **[Kinsta]**: SSH public key added to MyKinsta dashboard

### Premium Plugins
- `auth.json` file present in project root for Composer authentication
- Valid licenses for: [list premium plugins requiring licenses]

### Network Access
- Stable internet connection for database refresh operations
- VPN/firewall allows SSH access to hosting provider
- Access to hosting provider dashboards for initial authentication setup

## Affected URLs

### Development URLs
- **Primary Site**: `https://[project-name].ddev.site`
- **Admin Dashboard**: `https://[project-name].ddev.site/wp-admin`
- **PhpMyAdmin**: `https://[project-name].ddev.site:8037`
- **Mail Capture**: `https://[project-name].ddev.site:8026`

### Quick Access Commands
```bash
ddev wp-open          # Opens primary site
ddev wp-open admin    # Opens admin dashboard
ddev phpmyadmin       # Opens database interface
```

## Deploy Notes

### Team Onboarding
New team members will need:
1. **DDEV installed**: [Installation guide](https://ddev.readthedocs.io/en/latest/users/install/ddev-installation/)
2. **Provider authentication**: SSH keys or tokens configured
3. **Premium plugin access**: `auth.json` file (if applicable)
4. **Initial setup**: `ddev project-init` after cloning

### Existing Workflow Compatibility
- **Existing Docksal users**: Can continue using existing workflow
- **CI/CD pipelines**: No changes required (builds happen in hosting environment)
- **Deployment process**: Unchanged (git-based deployment continues as normal)

### Dependencies
- **Docker**: Required for DDEV
- **Git**: For version control and deployment
- **Node.js**: Managed automatically by add-on via NVM
- **Composer**: Managed by DDEV

## Breaking Changes

**None** - This is an additive change that preserves all existing workflows.

## Additional Notes

### Performance Benefits
- **Smart database refresh**: 12-hour backup age detection reduces unnecessary operations
- **Asset optimization**: Modern webpack-based build system
- **Local caching**: Redis integration for improved local performance

### Security Improvements
- **Isolated environment**: DDEV containers provide isolation
- **Secure connections**: SSH-based provider access
- **Environment variables**: Secure credential management

### Team Benefits
- **Consistent environments**: Same setup across all team members
- **Simplified onboarding**: Single command initialization
- **Integrated tooling**: Database, theme, and testing tools in one place

---

**Testing Checklist**:
- [ ] Fresh environment setup works
- [ ] Database operations function correctly
- [ ] Theme development workflow operational
- [ ] All custom commands available and working
- [ ] Services (PhpMyAdmin, Redis) accessible
- [ ] Hosting provider integration functional
```

## Key Validation Flow Patterns

### Pattern 1: Addon Already in PR
If the add-on is already included in the PR:
```bash
# Skip installation, note it's included
git checkout pr-branch-name

# Skip to authentication setup
[Configure provider tokens/keys]

# Initialize environment
ddev project-init

# Test functionality
[Validation steps]
```

### Pattern 2: Addon Needs Installation
If the add-on needs to be installed:
```bash
git checkout pr-branch-name

# Install add-on
ddev add-on get kanopi/ddev-kanopi-wp

# Configure provider
ddev project-configure

# Initialize environment
ddev project-init

# Test functionality
[Validation steps]
```

### Pattern 3: Already Configured
If configuration is already done:
```bash
git checkout pr-branch-name

# Skip configuration, go straight to init
ddev project-init

# Test functionality
[Validation steps]
```

## Common PR Validation Issues

### Authentication Problems
- **Missing tokens/keys**: Ensure proper authentication setup before testing
- **Incorrect permissions**: Verify SSH keys have proper access
- **Network restrictions**: Check VPN/firewall settings

### Configuration Issues
- **Wrong provider selected**: Re-run `ddev project-configure` if needed
- **Incorrect paths**: Verify theme paths and remote paths for SSH providers
- **Missing variables**: Check environment variables with `ddev exec printenv`

### Service Integration Problems
- **Port conflicts**: Ensure no other services running on DDEV ports
- **Docker issues**: Restart Docker if containers fail to start
- **Permission problems**: Check file permissions on theme directories

## Best Practices for PR Creation

1. **Test thoroughly**: Validate all functionality before creating PR
2. **Document assumptions**: Be explicit about authentication and setup requirements
3. **Include screenshots**: Visual confirmation of working functionality
4. **Provide rollback**: Document how to return to previous development setup
5. **Update team**: Notify team of new development workflow and requirements

This comprehensive approach ensures that your pull requests provide all necessary information for reviewers to understand, test, and approve the DDEV integration changes.