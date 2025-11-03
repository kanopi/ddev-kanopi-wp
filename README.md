# DDEV Kanopi WordPress Add-on

[![tests](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/kanopi/ddev-kanopi-wp/actions/workflows/test.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/kanopi/ddev-kanopi-wp)](https://github.com/kanopi/ddev-kanopi-wp/commits)
[![release](https://img.shields.io/github/v/release/kanopi/ddev-kanopi-wp)](https://github.com/kanopi/ddev-kanopi-wp/releases/latest)
![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)
[![Documentation](https://img.shields.io/badge/docs-mkdocs-blue.svg)](https://kanopi.github.io/ddev-kanopi-wp/)

A comprehensive DDEV add-on that provides Kanopi's battle-tested workflow for WordPress development with multi-provider hosting support.

## 🚀 Quick Start

```bash
# Intialize a project
ddev config --project-type=wordpress 

# Install the add-on
ddev add-on get kanopi/ddev-kanopi-wp

# Configure your hosting provider
ddev project-configure

# Initialize your development environment
ddev project-init
```

## ✨ Features

- **26+ Custom Commands** - Complete WordPress development workflow
- **Multi-Provider Hosting** - Pantheon, WPEngine, and Kinsta support
- **Smart Database Refresh** - 12-hour backup age detection
- **Modern Asset Pipeline** - Webpack with `@wordpress/scripts`
- **Block Development** - WordPress block scaffolding and tooling
- **E2E Testing** - Cypress integration with user management
- **Performance Tools** - Critical CSS generation and optimization
- **Service Integration** - Redis support for object caching

## 📚 Documentation

**[📖 Complete Documentation](https://kanopi.github.io/ddev-kanopi-wp/)**

### Quick Links

| Topic | Description |
|-------|-------------|
| **[🏁 Getting Started](https://kanopi.github.io/ddev-kanopi-wp/installation/)** | Installation and setup guide |
| **[⚙️ Configuration](https://kanopi.github.io/ddev-kanopi-wp/configuration/)** | Hosting provider setup |
| **[🛠 Commands](https://kanopi.github.io/ddev-kanopi-wp/commands/)** | Complete command reference |
| **[🎨 Theme Development](https://kanopi.github.io/ddev-kanopi-wp/theme-development/)** | Asset compilation and blocks |
| **[🗄 Database Operations](https://kanopi.github.io/ddev-kanopi-wp/database-operations/)** | Smart refresh and migrations |
| **[🧪 Testing](https://kanopi.github.io/ddev-kanopi-wp/testing/)** | Cypress E2E and automated testing |
| **[☁️ Hosting Providers](https://kanopi.github.io/ddev-kanopi-wp/hosting-providers/)** | Platform-specific guides |
| **[🔧 Troubleshooting](https://kanopi.github.io/ddev-kanopi-wp/troubleshooting/)** | Common issues and solutions |

## 🏗 Key Commands

| Command | Description |
|---------|-------------|
| `ddev project-init` | Complete development environment setup |
| `ddev project-configure` | Interactive configuration wizard |
| `ddev db-refresh [env]` | Smart database refresh with backup detection |
| `ddev theme-watch` | Start theme development with file watching |
| `ddev theme-create-block <name>` | Create new WordPress blocks |
| `ddev wp-open [admin]` | Open site or admin in browser |

[**See all 26+ commands →**](https://kanopi.github.io/ddev-kanopi-wp/commands/)

## 🌐 Hosting Provider Support

| Provider | Authentication | Features | Docroot |
|----------|---------------|----------|---------|
| **[Pantheon](https://kanopi.github.io/ddev-kanopi-wp/providers/pantheon/)** | Machine Token | Terminus integration, multidev support | `web` (recommended) or root (legacy) |
| **[WPEngine](https://kanopi.github.io/ddev-kanopi-wp/providers/wpengine/)** | SSH Key (local config) | Nightly backup utilization | Configurable |
| **[Kinsta](https://kanopi.github.io/ddev-kanopi-wp/providers/kinsta/)** | SSH Key | Direct server access | `public` |

## 📋 Installation Options

### Existing DDEV Projects
```bash
ddev add-on get kanopi/ddev-kanopi-wp
ddev project-configure
ddev restart
```

### New Projects
```bash
# Initialize DDEV
ddev config --project-type=wordpress

# Install add-on
ddev add-on get kanopi/ddev-kanopi-wp
ddev project-configure
ddev project-init
```

[**Detailed installation guide →**](https://kanopi.github.io/ddev-kanopi-wp/installation/)

## 🔧 Management

```bash
# Update to latest version
ddev add-on get kanopi/ddev-kanopi-wp
ddev restart

# View installed add-ons
ddev add-on list

# Remove add-on
ddev add-on remove kanopi-wp
```

## 📖 Project Integration

### For Project Maintainers

- **[README Updates](https://kanopi.github.io/ddev-kanopi-wp/readme-updates/)** - Template for updating project documentation
- **[Pull Request Guide](https://kanopi.github.io/ddev-kanopi-wp/pull-requests/)** - Comprehensive PR template and validation

### For Developers

- **[wp-config.php Setup](https://kanopi.github.io/ddev-kanopi-wp/wp-config-setup/)** - Integration with existing WordPress configurations
- **[Environment Variables](https://kanopi.github.io/ddev-kanopi-wp/environment-variables/)** - Complete configuration reference
- **[Contributing Guide](https://kanopi.github.io/ddev-kanopi-wp/contributing/)** - How to contribute to the add-on

## 🤝 Support

- **[📚 Documentation](https://kanopi.github.io/ddev-kanopi-wp/)** - Comprehensive guides and references
- **[🐛 Issues](https://github.com/kanopi/ddev-kanopi-wp/issues)** - Bug reports and feature requests
- **[💬 Discussions](https://github.com/kanopi/ddev-kanopi-wp/discussions)** - Community support and questions

## 📄 License

This project is licensed under the GNU General Public License v2 - see the [LICENSE](LICENSE) file for details.

---

**Originally Contributed by [Kanopi Studios](https://kanopi.com)**
