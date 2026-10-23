# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `REMOTE_SSHPASS`: password authentication for the `remote` provider. When set, `db-refresh` wraps
  ssh/rsync in `sshpass` (and errors clearly if `sshpass` isn't installed in the web container).
- `ddev/ddev-nvm` is now an add-on dependency. DDEV v1.25+ no longer ships nvm, so `theme-install`
  failed with `nvm: command not found`.

### Fixed
- `project-init`, `project-wp` and `project-configure` read `docroot: ""` as the literal `""`, so an
  application-root docroot broke them: `project-init` looked for `""/wp-content/mu-plugins/vendor/autoload.php`,
  retried Composer three times and exited before the database refresh.
- `project-wp` fell back to a `web` docroot for the `remote` provider, so it downloaded a second copy
  of WordPress into `web/`. It now follows the DDEV docroot like Pantheon and WPEngine.
- `project-init` checks the Composer autoloader inside the container, so Mutagen sync lag on the host
  can't report it missing.
- `project-init` skips `theme-install` when the theme has no `package.json`.
- `refresh-remote.sh` strips `DEFINER` clauses before import. Dumps containing views or triggers
  failed with `ERROR 1227 ... need SUPER` because the ddev `db` user can't create them as another user.

## [1.2.13] - 2026-01-13

### Added
- **Remote SSH Hosting Provider Support**: Added support for generic SSH-based hosting providers
  - New `remote` hosting provider option in `project-configure`
  - Remote SSH configuration wizard for host, port, user, path, and domain settings
  - New `scripts/refresh-remote.sh` script for database refresh from remote SSH hosts
  - Support in `db-refresh` command for remote provider (no environment parameter needed)
  - Remote domain configuration for search/replace operations
  - SSH connectivity testing with detailed error messages
  - Automatic database age detection (12-hour threshold) for remote hosts
  - Configuration variables: `REMOTE_HOST`, `REMOTE_PORT`, `REMOTE_USER`, `REMOTE_PATH`, `REMOTE_DOMAIN`
  - Proxy URL configuration for Remote SSH hosting providers

### Changed
- Updated `db-refresh` command to support Remote SSH hosting provider
- Updated `project-configure` to include Remote SSH configuration wizard
- Updated `load-config.sh` to include Remote SSH-specific configuration section
- Enhanced hosting provider documentation to include Remote SSH setup instructions

### Fixed
- Fixed docroot path resolution in `refresh-remote.sh` for improved reliability
- Fixed post-refresh cleanup to ensure proper working directory (cd to docroot)
- Removed stray character in `nginx-site.conf` file
- Removed unnecessary `#ddev-generated` comment from nginx configuration

## [1.2.12] - 2026-01-12

### Changed
- Simplified installation process by removing Pantheon mu-plugin compatibility checks
- Reduced installation script complexity and maintenance overhead

### Removed
- Post-install mu-plugin loader detection and disable logic from `install.yaml`
- Removal action that restored disabled mu-plugin loaders during uninstallation
- Test cases for Pantheon mu-plugin handling

## [1.2.11] - 2025-01-XX

### Added
- Initial changelog creation for version tracking

### Note
Previous releases were not tracked in a changelog format. See [GitHub Releases](https://github.com/kanopi/ddev-kanopi-wp/releases) for historical information.

[Unreleased]: https://github.com/kanopi/ddev-kanopi-wp/compare/1.2.13...HEAD
[1.2.13]: https://github.com/kanopi/ddev-kanopi-wp/compare/1.2.12...1.2.13
[1.2.12]: https://github.com/kanopi/ddev-kanopi-wp/compare/1.2.11...1.2.12
[1.2.11]: https://github.com/kanopi/ddev-kanopi-wp/releases/tag/1.2.11
