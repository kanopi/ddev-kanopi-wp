# Contributing

Contributions are welcome! This guide will help you contribute effectively to the DDEV Kanopi WordPress add-on.

## Getting Started

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Add/update tests
5. Submit a pull request

### Local Development
```bash
# Clone your fork
git clone https://github.com/your-username/ddev-kanopi-wp.git
cd ddev-kanopi-wp

# Test add-on installation locally
ddev add-on get /path/to/ddev-kanopi-wp

# Test removal
ddev add-on remove kanopi-wp
```

## Development Guidelines

### Code Standards
- **Testing**: All commands must be tested in the `tests/test.bats` file
- **Documentation**: Update documentation for new features
- **Code Style**: Follow existing conventions and patterns
- **Backwards Compatibility**: Maintain alias support for renamed commands

### Command Development

#### Host Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e
# Command logic here
```

#### Web Command Template
```bash
#!/usr/bin/env bash

## Description: Brief description of what the command does
## Usage: command-name [arguments]
## Example: "ddev command-name arg1 arg2"

set -e

# Load Kanopi configuration
source /var/www/html/.ddev/scripts/load-config.sh
load_kanopi_config

# Command logic here
# Variables like $HOSTING_PROVIDER, $THEME, etc. are now available
```

### Naming Conventions

#### Command Naming
- Use descriptive, action-oriented names
- Follow pattern: `category-action` (e.g., `theme-build`, `db-refresh`)
- Provide meaningful aliases for convenience
- Include namespace aliases (e.g., `theme:build`)

#### Variable Naming
- Use UPPER_CASE for environment variables
- Prefix with category: `HOSTING_*`, `WP_*`, `THEME*`
- Be consistent across providers

## Testing Requirements

### Automated Testing
All changes must pass:
- **GitHub Actions**: Standard add-on testing
- **CircleCI**: Extended integration testing
- **Bats Tests**: Component functionality testing

### Test Development
```bash
# Run bats tests locally
bats tests/test.bats

# Add new tests for new features
# Follow existing test patterns in tests/test.bats
```

### Test Categories
1. **Installation Tests**: Verify add-on installs correctly
2. **Command Tests**: Test all custom commands
3. **Provider Tests**: Test hosting provider integrations
4. **Configuration Tests**: Validate configuration management

## Cross-Repository Development

### Companion Project
When working on this WordPress add-on, also consider the companion Drupal add-on (`ddev-kanopi-drupal`) to maintain consistency.

#### Maintaining Feature Parity
Both add-ons should maintain feature parity where applicable:
- **Shared commands**: Database, theme, testing, and utility commands
- **Configuration patterns**: Environment variables and file structures
- **Documentation**: Consistent README files and examples
- **CI/CD**: Identical GitHub Actions and CircleCI configurations

#### Development Workflow
When making changes:
1. **Assess applicability**: Determine if changes apply to Drupal add-on
2. **Mirror changes**: Make equivalent changes in both repositories
3. **Test both**: Ensure functionality in WordPress and Drupal contexts
4. **Update documentation**: Keep documentation synchronized
5. **Maintain aliases**: Preserve backward compatibility

#### Platform Differences to Respect
- **WordPress-specific**: Block creation, admin user management, multi-provider hosting
- **Drupal-specific**: Recipe commands, Pantheon-focused features
- **File structures**: Different directory conventions
- **Hosting support**: WordPress supports more providers

### Repository Locations
- **WordPress add-on**: https://github.com/kanopi/ddev-kanopi-wp
- **Drupal add-on**: https://github.com/kanopi/ddev-kanopi-drupal

## Feature Development

### Adding New Commands

#### 1. Create Command File
```bash
# For web commands (run inside container)
touch .ddev/commands/web/new-command

# For host commands (run on host system)
touch .ddev/commands/host/new-command
```

#### 2. Implement Command Logic
- Follow existing patterns
- Load configuration when needed
- Include proper error handling
- Add helpful output messages

#### 3. Add Command Aliases
Update `install.yaml` to include aliases:
```yaml
post_install_actions:
  - exec: "ln -sf theme-build /var/www/html/.ddev/commands/web/production"
  - exec: "ln -sf new-command /var/www/html/.ddev/commands/web/alias-name"
```

#### 4. Update Documentation
- Add command to README command table
- Update relevant documentation files
- Include usage examples

#### 5. Write Tests
Add tests to `tests/test.bats`:
```bash
@test "new-command works correctly" {
  run ddev new-command
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Expected output" ]]
}
```

### Adding Provider Support

#### 1. Configuration Variables
Define provider-specific variables in configuration system:
- Add to `project-configure` command
- Update `load-config.sh` generation
- Document in environment variables guide

#### 2. Provider-Specific Logic
Add provider detection and logic to relevant commands:
```bash
case "$HOSTING_PROVIDER" in
    "new-provider")
        echo "Using new provider operations"
        # Provider-specific logic
        ;;
esac
```

#### 3. Documentation
- Create provider-specific documentation
- Update hosting providers overview
- Include troubleshooting section

#### 4. Testing
- Add provider-specific tests
- Test authentication and basic operations
- Validate configuration management

## Documentation Contributions

### MkDocs Structure
Documentation uses MkDocs with Material theme:
- **Source**: `/docs/` directory
- **Configuration**: `mkdocs.yml`
- **Deployment**: GitHub Pages via GitHub Actions

### Adding Documentation
1. **Create markdown files** in appropriate `/docs/` subdirectory
2. **Update `mkdocs.yml`** navigation structure
3. **Use proper markdown formatting** with MkDocs extensions
4. **Include code examples** with proper syntax highlighting
5. **Add cross-references** between related documentation

### Documentation Standards
- **Clear headings**: Use descriptive section headers
- **Code examples**: Include working examples for all features
- **Cross-references**: Link between related documentation
- **Screenshots**: Add visual guides where helpful
- **Keep current**: Update docs with code changes

### Local Documentation Development

#### Prerequisites
- Python 3.7+
- pip (Python package installer)

#### Setup
```bash
# Clone the repository
git clone https://github.com/kanopi/ddev-kanopi-wp.git
cd ddev-kanopi-wp

# Install MkDocs and dependencies
pip install -r requirements.txt

# Alternative: Install globally
pip install mkdocs-material mkdocs-git-revision-date-localized-plugin
```

#### Development Workflow
```bash
# Serve documentation locally with hot reload
mkdocs serve

# Access at: http://localhost:8000
# Documentation updates automatically on file changes

# Build documentation for production
mkdocs build

# The built site will be in ./site/ directory
```

#### MkDocs Commands
```bash
# Serve with specific host/port
mkdocs serve --dev-addr=0.0.0.0:8080

# Strict mode (fail on warnings)
mkdocs build --strict

# Clean build directory
mkdocs build --clean

# Get help
mkdocs --help
```

#### Documentation Structure
```
docs/
├── index.md                 # Homepage
├── installation.md          # Installation guide
├── configuration.md         # Configuration guide
├── wp-config-setup.md      # wp-config integration
├── commands.md             # Command reference
├── database-operations.md  # Database management
├── theme-development.md    # Theme workflow
├── testing.md              # Testing framework
├── hosting-providers.md    # Provider overview
├── providers/              # Provider-specific guides
│   ├── pantheon.md
│   ├── wpengine.md
│   └── kinsta.md
├── environment-variables.md # Configuration reference
├── troubleshooting.md      # Common issues
├── contributing.md         # This file
├── readme-updates.md       # Project integration
└── pull-requests.md        # PR templates
```

#### Adding New Documentation
1. **Create markdown file** in appropriate directory
2. **Update mkdocs.yml** navigation section
3. **Use proper frontmatter** if needed
4. **Test locally** with `mkdocs serve`
5. **Follow existing patterns** for consistency

#### Documentation Guidelines
- **Use descriptive headings** with proper hierarchy
- **Include code examples** with syntax highlighting
- **Add cross-references** between related docs
- **Keep examples current** and working
- **Use admonitions** for important notes
- **Include screenshots** for UI elements

## Pull Request Process

### Before Submitting
1. **Run all tests**: Ensure bats tests pass
2. **Update documentation**: Include relevant documentation updates
3. **Test multiple scenarios**: Verify functionality across providers
4. **Follow code standards**: Consistent with existing patterns

### Pull Request Template
Include in your PR description:
- **Summary**: What does this change do?
- **Testing**: How was this tested?
- **Documentation**: What documentation was added/updated?
- **Breaking Changes**: Any backwards compatibility concerns?
- **Related Issues**: Link to related issues or discussions

### Review Process
- **Automated tests**: GitHub Actions and CircleCI must pass
- **Code review**: Maintainer review of code and documentation
- **Testing review**: Verification of test coverage
- **Documentation review**: Accuracy and completeness of docs

## Release Process

### Versioning
- Follow [Semantic Versioning](https://semver.org/)
- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, backwards compatible

### Release Checklist
1. **Update version numbers** in relevant files
2. **Update CHANGELOG.md** with release notes
3. **Tag release** with appropriate version
4. **Deploy documentation** to GitHub Pages
5. **Announce release** in appropriate channels

## Getting Help

### Development Questions
- **GitHub Discussions**: General development questions
- **GitHub Issues**: Bug reports and feature requests
- **DDEV Community**: General DDEV development support

### Code Review
- Request reviews from maintainers
- Participate in code review discussions
- Be responsive to feedback and suggestions

### Testing Support
- Ask for help with complex testing scenarios
- Request guidance on cross-provider testing
- Share testing best practices

## Recognition

### Contributors
All contributors are recognized in:
- **GitHub contributors list**
- **Project documentation**
- **Release notes** for significant contributions

### Maintainership
Active contributors may be invited to become maintainers with:
- **Commit access** to the repository
- **Review responsibilities** for pull requests
- **Release management** participation

Thank you for contributing to the DDEV Kanopi WordPress add-on!