# Theme Development

Comprehensive theme development workflow including asset compilation, block creation, and performance optimization.

## Setup

### Install Theme Development Tools
```bash
# Install Node.js, NPM, and build tools (one-time setup)
ddev theme-install

# Start theme development with file watching
ddev theme-watch

# Build production assets
ddev theme-build
```

## Asset Compilation

The add-on uses `@wordpress/scripts` for modern WordPress asset compilation:

### Development Workflow
```bash
# Start development server with file watching
ddev theme-watch

# Run specific npm commands in theme directory
ddev theme-npm run build
ddev theme-npm install

# Run npx commands
ddev theme-npx webpack --watch
```

### Production Build
```bash
# Build production assets with optimization
ddev theme-build
```

## Block Development

### Creating New Blocks
```bash
# Create a new WordPress block with scaffolding
ddev theme-create-block my-custom-block

# Start development server
ddev theme-watch
```

Your block will be created in `web/wp-content/themes/[theme]/assets/src/blocks/my-custom-block/` with:

- `block.json` - Block metadata and configuration
- `index.js` - Block registration and entry point
- `edit.js` - Editor interface and controls
- `save.js` - Frontend output (or `render.php` for server-side rendering)
- `style.scss` - Frontend styles
- `editor.scss` - Editor-specific styles
- `view.js` - Frontend JavaScript functionality

### Block Structure

#### block.json
```json
{
  "apiVersion": 2,
  "name": "theme/my-custom-block",
  "title": "My Custom Block",
  "category": "widgets",
  "attributes": {
    "content": {
      "type": "string",
      "default": ""
    }
  },
  "editorScript": "file:./index.js",
  "editorStyle": "file:./editor.scss",
  "style": "file:./style.scss",
  "viewScript": "file:./view.js"
}
```

#### Modern Block Development
- **React/JSX support**: Full React component development
- **SCSS compilation**: Automatic SCSS to CSS compilation
- **Asset optimization**: Webpack-based bundling and optimization
- **Hot reloading**: Live development with instant updates

## Performance Optimization

### Critical CSS Generation

```bash
# Install Critical CSS tools (one-time setup)
ddev critical-install

# Generate critical CSS for improved performance
ddev critical-run
```

Critical CSS helps improve page load performance by:
- Inlining above-the-fold CSS
- Deferring non-critical CSS loading
- Reducing render-blocking resources

## Theme Management

### Theme Activation
```bash
# Activate the configured theme
ddev theme-activate
```

### Theme Directory Management
The add-on automatically detects and works with your theme directory based on the `THEME` configuration variable.

## Build System Features

### Webpack Configuration
The build system includes:
- **ES6+ JavaScript transpilation**
- **SCSS/Sass compilation**
- **Asset optimization and minification**
- **Source maps for development**
- **Hot module replacement**

### File Watching
Development mode includes:
- **Live reload**: Browser refreshes on changes
- **SCSS compilation**: Instant style updates
- **JavaScript bundling**: Real-time script updates
- **Asset processing**: Automatic image optimization

## Advanced Workflows

### Custom npm Scripts
Run any npm script in your theme:

```bash
# Custom build scripts
ddev theme-npm run custom-build

# Linting and quality checks
ddev theme-npm run lint
ddev theme-npm run test

# Custom development tasks
ddev theme-npm run dev:custom
```

### Node Version Management
The add-on uses `.nvmrc` files for Node.js version management:
- Automatically installs correct Node.js version
- Ensures consistent development environment
- Supports team-wide Node.js version consistency

## Integration with WordPress

### Enqueue Scripts and Styles
Your theme's `functions.php` should properly enqueue the compiled assets:

```php
function theme_enqueue_assets() {
    // Enqueue compiled CSS
    wp_enqueue_style(
        'theme-style',
        get_template_directory_uri() . '/assets/dist/main.css',
        [],
        filemtime(get_template_directory() . '/assets/dist/main.css')
    );

    // Enqueue compiled JS
    wp_enqueue_script(
        'theme-script',
        get_template_directory_uri() . '/assets/dist/main.js',
        [],
        filemtime(get_template_directory() . '/assets/dist/main.js'),
        true
    );
}
add_action('wp_enqueue_scripts', 'theme_enqueue_assets');
```

### Block Registration
Blocks are automatically registered when using the proper file structure:

```php
// In your theme's functions.php
function register_custom_blocks() {
    register_block_type(__DIR__ . '/assets/src/blocks/my-custom-block');
}
add_action('init', 'register_custom_blocks');
```

## Troubleshooting

### Node.js Version Issues
```bash
# Check Node.js version
ddev exec node --version

# Reinstall theme dependencies
ddev theme-install
```

### Build Errors
```bash
# Clear npm cache
ddev theme-npm cache clean --force

# Remove node_modules and reinstall
ddev exec rm -rf /var/www/html/wp-content/themes/[theme]/node_modules
ddev theme-install
```

### Asset Loading Issues
- Verify file paths in enqueue functions
- Check file permissions on compiled assets
- Ensure proper cache busting with `filemtime()`

## Best Practices

### Development Workflow
1. **Start with theme setup**: `ddev theme-install`
2. **Use file watching**: `ddev theme-watch` during development
3. **Build for production**: `ddev theme-build` before deployment
4. **Test thoroughly**: Verify assets load properly in all environments

### Performance Optimization
- Generate Critical CSS for important pages
- Optimize images during build process
- Use proper cache busting techniques
- Minimize and compress assets for production

### Team Collaboration
- Commit `.nvmrc` file for Node.js version consistency
- Document custom npm scripts in project README
- Use consistent file structure across projects
- Share build configurations and best practices