# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
