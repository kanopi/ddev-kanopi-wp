# DDEV Kanopi WordPress Add-on

[![tests](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/kanopi/ddev-kanopi-wp)](https://github.com/kanopi/ddev-kanopi-wp/commits)
[![release](https://img.shields.io/github/v/release/kanopi/ddev-kanopi-wp)](https://github.com/kanopi/ddev-kanopi-wp/releases/latest)
![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

A comprehensive DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development. This add-on includes complete tooling for modern WordPress development with multi-provider hosting support.

## Features

This add-on provides:

- **26 Custom Commands**: Complete WordPress development workflow with namespaced commands
- **Multi-Provider Hosting**: Support for Pantheon, WPEngine, and Kinsta hosting platforms
- **Block Creation Tooling**: Command to generate custom WordPress blocks with proper scaffolding
- **Asset Compilation**: Webpack-based build system using `@wordpress/scripts`
- **Testing Framework**: Cypress E2E testing with user management
- **Database Management**: Smart refresh system with 12-hour backup detection
- **Theme Development**: Node.js, NPM, and build tools with file watching
- **Security & Performance**: Nginx configuration with headers and optimization
- **Services Integration**: Redis for Pantheon object caching (auto-installed for Pantheon)
- **Environment Configuration**: Clean configuration system using environment variables

## Quick Start

Get started with the add-on in just a few steps:

```bash
# Install the add-on
ddev add-on get kanopi/ddev-kanopi-wp

# Configure your hosting provider and project settings
ddev project-configure

# Initialize your development environment
ddev project-init
```

## Documentation Structure

- **[Installation](installation.md)**: Complete installation guide for new and existing projects
- **[Configuration](configuration.md)**: Set up hosting providers and project settings
- **[Commands](commands.md)**: Complete reference of all 26+ available commands
- **[Hosting Providers](hosting-providers.md)**: Platform-specific setup guides
- **[Theme Development](theme-development.md)**: Asset compilation and block creation
- **[Troubleshooting](troubleshooting.md)**: Common issues and solutions

## Key Commands

| Command | Description |
|---------|-------------|
| `ddev project-init` | Complete development environment setup |
| `ddev project-configure` | Interactive configuration wizard |
| `ddev db-refresh [env]` | Smart database refresh with backup detection |
| `ddev theme-watch` | Start theme development with file watching |
| `ddev theme-create-block <name>` | Create new WordPress blocks |
| `ddev wp-open [admin]` | Open site or admin in browser |

## Multi-Provider Support

The add-on supports all major WordPress hosting platforms:

- **[Pantheon](providers/pantheon.md)**: Full Terminus integration with backup management
- **[WPEngine](providers/wpengine.md)**: SSH-based operations with specific key handling
- **[Kinsta](providers/kinsta.md)**: Direct SSH access with custom configurations

---

**Originally Contributed by [Kanopi Studios](https://kanopi.com)**