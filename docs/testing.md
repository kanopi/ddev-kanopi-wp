# Testing

Comprehensive testing framework including Cypress E2E testing, automated CI/CD testing, and local development testing.

## Cypress E2E Testing

### Setup and Installation
```bash
# Install Cypress E2E testing dependencies (one-time setup)
ddev cypress-install

# Create default admin user for Cypress testing
ddev cypress-users
```

### Running Tests
```bash
# Open Cypress interactive interface
ddev cypress-run open

# Run tests in headless mode
ddev cypress-run run

# Run specific test suite
ddev cypress-run run --spec "cypress/e2e/login.cy.js"
```

### Cypress Configuration

The add-on provides:
- **Pre-configured Cypress setup** for WordPress
- **User management** with default admin credentials
- **Environment support** for multiple testing environments
- **WordPress-specific helpers** and commands

### Test User Management
```bash
# Create/restore admin user for testing
ddev cypress-users

# This creates a user with:
# Username: admin (configurable)
# Password: admin (configurable)
# Email: admin@example.com (configurable)
```

## Automated Testing (CI/CD)

### GitHub Actions Testing
The add-on includes comprehensive automated testing via GitHub Actions:

- **Standard DDEV add-on validation**
- **Extended bats tests** for WordPress-specific functionality
- **Multi-provider testing** across hosting platforms
- **Integration testing** with real hosting provider APIs

### CircleCI Integration
Machine-based testing with:
- **Comprehensive validation** of all commands
- **Multi-environment testing**
- **Performance benchmarking**
- **Cross-platform compatibility** testing

## Local Development Testing

### Bats Testing Framework
```bash
# Run comprehensive bats tests
bats tests/test.bats

# Run with verbose output
bats --verbose-run tests/test.bats
```

### Component Testing
```bash
# Install bats if not already installed
# macOS: brew install bats-core
# Linux: See https://bats-core.readthedocs.io/en/stable/installation.html

# Run specific test suites
bats tests/test-commands.bats
bats tests/test-providers.bats
```

## Testing Strategy

| Test Level | Purpose | When to Use |
|------------|---------|-------------|
| **GitHub Actions** | Automated validation | Every push/PR |
| **CircleCI** | Machine-based validation | Continuous integration |
| **Bats Tests** | Component functionality | Feature development |
| **Cypress E2E** | User workflow testing | Major releases |

## Test Environment Setup

### Isolated Testing Environment
The add-on creates isolated testing environments:

```bash
# Create isolated Pantheon test environment
ddev pantheon-testenv my-test fresh

# Work in isolated environment
ddev pantheon-testenv existing-feature existing
```

### Environment Variables for Testing
Pre-configured environment variables to avoid interactive prompts during testing:

```bash
# Testing with pre-configured variables
export HOSTING_PROVIDER=pantheon
export HOSTING_SITE=test-site
export HOSTING_ENV=dev
```

## Debugging Failed Tests

### Test Environment Inspection
```bash
# Navigate to test environment (if using test-install.sh)
cd tests/test-install/wordpress

# Check DDEV status
ddev describe

# Verify environment variables
ddev exec printenv | grep -E "(HOSTING|THEME|WP_)"

# Check installed add-ons
ddev add-on list
```

### Cleanup Test Environment
```bash
# Cleanup when done
ddev delete -Oy
cd ../../..
rm -rf tests/test-install
```

## Cypress Test Examples

### Basic WordPress Tests
```javascript
// cypress/e2e/wordpress-basic.cy.js
describe('WordPress Basic Functionality', () => {
  it('Should load the homepage', () => {
    cy.visit('/')
    cy.contains('WordPress')
  })

  it('Should allow admin login', () => {
    cy.visit('/wp-admin')
    cy.get('#user_login').type('admin')
    cy.get('#user_pass').type('admin')
    cy.get('#wp-submit').click()
    cy.contains('Dashboard')
  })
})
```

### Theme Testing
```javascript
// cypress/e2e/theme-functionality.cy.js
describe('Theme Functionality', () => {
  beforeEach(() => {
    cy.login('admin', 'admin')
  })

  it('Should activate custom theme', () => {
    cy.visit('/wp-admin/themes.php')
    cy.contains('My Custom Theme').click()
    cy.get('.activate').click()
    cy.contains('activated')
  })
})
```

## Performance Testing

### Critical CSS Testing
```bash
# Install and run Critical CSS generation
ddev critical-install
ddev critical-run

# Verify Critical CSS output
ls -la wp-content/themes/[theme]/assets/dist/critical/
```

### Asset Loading Tests
- **JavaScript loading**: Verify all JS assets load properly
- **CSS compilation**: Check SCSS compilation and loading
- **Image optimization**: Test image processing and delivery

## Integration Testing

### Database Operations Testing
```bash
# Test database refresh functionality
ddev db-refresh

# Test theme installation
ddev theme-install

# Test block creation
ddev theme-create-block test-block
```

### Hosting Provider Integration Testing
```bash
# Test Pantheon integration
ddev pantheon-terminus site:list

# Test SSH authentication
ddev auth ssh

# Test environment creation
ddev pantheon-testenv integration-test fresh
```

## Continuous Testing

### Pre-commit Hooks
The add-on includes Lefthook git hooks for:
- **Code quality checks**
- **Automated testing** before commits
- **Asset compilation** verification
- **Configuration validation**

### Automated Quality Checks
- **PHP linting** and code standards
- **JavaScript/CSS validation**
- **WordPress coding standards**
- **Security vulnerability scanning**

## Best Practices

### Test Development
1. **Write tests first**: TDD approach for new features
2. **Test all providers**: Ensure compatibility across hosting platforms
3. **Use realistic data**: Test with production-like datasets
4. **Automate everything**: Minimize manual testing requirements

### CI/CD Integration
1. **Run tests on every commit**: Catch issues early
2. **Test multiple environments**: Dev, staging, production
3. **Performance benchmarking**: Track performance over time
4. **Security scanning**: Automated vulnerability detection

### Local Testing
1. **Test before commits**: Use pre-commit hooks
2. **Regular test runs**: Schedule periodic comprehensive testing
3. **Environment cleanup**: Always clean up test environments
4. **Documentation**: Keep test documentation up to date

## Troubleshooting Tests

### Common Issues
- **Authentication failures**: Check SSH keys and tokens
- **Network timeouts**: Adjust timeout settings for slow connections
- **Environment conflicts**: Ensure clean test environments
- **Resource limitations**: Monitor memory and CPU usage during tests

### Debug Commands
```bash
# Enable verbose output
ddev cypress-run run --config video=false --browser chrome

# Check test logs
cat tests/test.log

# Verify test environment
ddev describe
ddev exec env | grep -E "(CYPRESS|TEST)"
```