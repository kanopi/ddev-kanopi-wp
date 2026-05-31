# Playwright Commands — ddev-kanopi-wp

Add three Playwright DDEV commands to the WordPress addon, parallel to the existing `cypress-*` commands. This makes `playwright-install`, `playwright-run`, and `playwright-users` available in any project that installs this addon.

---

## Commands to Add

### `commands/host/playwright-install` (new)

Mirrors `cypress-install` pattern but targets the project root (where `package.json` and `playwright.config.ts` live), not `tests/cypress/`.

```bash
#!/usr/bin/env bash
#ddev-generated

## Description: Install Playwright and browsers for e2e testing
## Usage: playwright-install
## Example: "ddev playwright-install"
## Aliases: playwright:install,pwi

# Make sure NVM works
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check for package.json at project root
if [ ! -f "${DDEV_APPROOT}/package.json" ]; then
    echo "❌ No package.json found at project root: ${DDEV_APPROOT}"
    echo "Please create a package.json with Playwright dependencies first."
    exit 1
fi

cd "${DDEV_APPROOT}" || exit 1

echo "Installing Playwright dependencies..."
npm install

echo "Installing Playwright browsers..."
npx playwright install --with-deps chromium firefox webkit

echo "Done. Run tests with: ddev playwright-run"
```

---

### `commands/host/playwright-run` (new)

Mirrors `cypress-run` pattern. Runs `npx playwright test` from the project root, injecting DDEV's primary URL as `BASE_URL`.

```bash
#!/usr/bin/env bash
#ddev-generated

## Description: Run Playwright e2e tests
## Usage: playwright-run [options]
## Example: "ddev playwright-run"
## Example: "ddev playwright-run --reporter=list"
## Example: "ddev playwright-run --ui"
## Example: "ddev playwright-run tests/e2e/specs/smoke.spec.ts"
## Aliases: playwright:run,pwr

# Make sure NVM works
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check for playwright config at project root
if [ ! -f "${DDEV_APPROOT}/playwright.config.ts" ] && [ ! -f "${DDEV_APPROOT}/playwright.config.js" ]; then
    echo "❌ No playwright.config.ts found at project root"
    echo "Please run 'ddev playwright-install' first."
    exit 1
fi

export BASE_URL="${DDEV_PRIMARY_URL}"
export WP_USERNAME="playwright"
export WP_PASSWORD="playwright"

cd "${DDEV_APPROOT}" || exit 1

echo "Running Playwright tests against ${BASE_URL}..."
npx playwright test "$@"

if [ -d "playwright-report" ]; then
    echo ""
    echo "View HTML report with: npx playwright show-report"
fi
```

---

### `commands/host/playwright-users` (new)

Mirrors `cypress-users` but creates four role-scoped users (admin, editor, author, subscriber) matching the Playwright convention established on spokaneairport.

```bash
#!/usr/bin/env bash
#ddev-generated

## Description: Create Playwright test users in WordPress
## Usage: playwright-users
## Example: "ddev playwright-users"
## Aliases: playwright:users,pwu

# Abort if anything fails
set -e

echo "Creating test users for Playwright tests..."

ddev exec "wp user create playwright playwright@test.local --role=administrator --user_pass=playwright --allow-root" 2>/dev/null \
    || ddev exec "wp user update playwright --user_pass=playwright --role=administrator --allow-root" 2>/dev/null
echo "Created/updated admin user: playwright / playwright"

ddev exec "wp user create playwright-editor playwright-editor@test.local --role=editor --user_pass=playwright --allow-root" 2>/dev/null \
    || ddev exec "wp user update playwright-editor --user_pass=playwright --role=editor --allow-root" 2>/dev/null
echo "Created/updated editor user: playwright-editor / playwright"

ddev exec "wp user create playwright-author playwright-author@test.local --role=author --user_pass=playwright --allow-root" 2>/dev/null \
    || ddev exec "wp user update playwright-author --user_pass=playwright --role=author --allow-root" 2>/dev/null
echo "Created/updated author user: playwright-author / playwright"

ddev exec "wp user create playwright-subscriber playwright-subscriber@test.local --role=subscriber --user_pass=playwright --allow-root" 2>/dev/null \
    || ddev exec "wp user update playwright-subscriber --user_pass=playwright --role=subscriber --allow-root" 2>/dev/null
echo "Created/updated subscriber user: playwright-subscriber / playwright"

echo ""
echo "=== Test users ready ==="
echo "Admin:      playwright / playwright"
echo "Editor:     playwright-editor / playwright"
echo "Author:     playwright-author / playwright"
echo "Subscriber: playwright-subscriber / playwright"
```

---

## Files to Modify

### `install.yaml` — add playwright commands to `removal_actions`

In the `removal_actions` block, in the `# Remove host commands` section, add:

```yaml
  rm -f commands/host/playwright-install 2>/dev/null || true
  rm -f commands/host/playwright-run 2>/dev/null || true
  rm -f commands/host/playwright-users 2>/dev/null || true
```

### `README.md` — add to the command reference table

Add these three rows alongside the existing `cypress-*` entries:

| Command | Description |
|---|---|
| `ddev playwright-install` | Install Playwright and browsers at project root |
| `ddev playwright-run [options]` | Run Playwright e2e tests (pass any `npx playwright test` flags) |
| `ddev playwright-users` | Create/update the four Playwright test users in WordPress |

### `docs/commands.md` — add to the command table and Testing category

**Add to the main table** (alongside the `cypress-*` rows):

```markdown
| `ddev playwright-install` | Host | Install Playwright and browsers for e2e testing | `ddev playwright-install` | pwi, playwright:install |
| `ddev playwright-run [options]` | Host | Run Playwright e2e tests | `ddev playwright-run --ui` | pwr, playwright:run |
| `ddev playwright-users` | Host | Create/update Playwright test users in WordPress | `ddev playwright-users` | pwu, playwright:users |
```

**Add to the "Testing & Quality Assurance" category section:**

```markdown
- `ddev playwright-install` - Install Playwright and browsers at project root
- `ddev playwright-run [options]` - Run Playwright e2e tests (accepts all `npx playwright test` flags)
- `ddev playwright-users` - Create/update the four role-scoped Playwright test users
```

**Update the command count** in the opening line from "26+" to "29+".

### `docs/testing.md` — add a Playwright section

Add a new top-level section **Playwright E2E Testing** after the existing **Cypress E2E Testing** section:

```markdown
## Playwright E2E Testing

### Setup and Installation
```bash
# Install Playwright and browsers (one-time setup per machine)
ddev playwright-install

# Create test users for role-based testing
ddev playwright-users
```

### Running Tests
```bash
# Run all tests (headless, all configured browsers)
ddev playwright-run

# Run interactively with the Playwright UI
ddev playwright-run --ui

# Run in headed mode (browsers visible)
ddev playwright-run --headed

# Run a single spec file
ddev playwright-run tests/e2e/specs/smoke.spec.ts

# Run only Chromium (faster)
ddev playwright-run --project=chromium
```

### Playwright Configuration

Playwright is configured at the **project root** (`playwright.config.ts`), not inside a subdirectory. Key settings:

- **Test directory**: `tests/e2e/specs/`
- **Utilities**: `tests/e2e/utils/` — config, login helper, WordPress fixtures
- **Auth state**: `tests/e2e/.auth/admin.json` (gitignored — generated at runtime)
- **Local browsers**: Chromium, Firefox, WebKit, Mobile Chrome, Mobile Safari
- **CI browsers**: Chromium only (faster)
- **Environment**: Reads `BASE_URL` from `.env.playwright` or DDEV's primary URL

### Test User Management
```bash
# Create or update all four Playwright test users
ddev playwright-users

# Users created:
# playwright        / playwright  (administrator)
# playwright-editor / playwright  (editor)
# playwright-author / playwright  (author)
# playwright-subscriber / playwright (subscriber)
```

### Viewing Reports
```bash
# Open the HTML report from the last run
npx playwright show-report
```
```

---

## Implementation Order

1. Create `commands/host/playwright-install`
2. Create `commands/host/playwright-run`
3. Create `commands/host/playwright-users`
4. Update `install.yaml` removal_actions
5. Update `README.md`
6. Update `docs/commands.md`
7. Update `docs/testing.md`
8. Commit, tag, push
9. In each consuming project: `ddev add-on update ddev-kanopi-wp` then `ddev restart`
