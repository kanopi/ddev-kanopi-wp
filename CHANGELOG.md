# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/kanopi/ddev-kanopi-wp/compare/1.2.12...HEAD
[1.2.12]: https://github.com/kanopi/ddev-kanopi-wp/compare/1.2.11...1.2.12
[1.2.11]: https://github.com/kanopi/ddev-kanopi-wp/releases/tag/1.2.11
