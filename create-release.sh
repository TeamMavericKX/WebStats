#!/bin/bash

# WebStats Release Script
# Creates a complete release package for WebStats

set -e

RELEASE_VERSION="${1:-$(date +%Y.%m.%d)}"
RELEASE_DIR="release/dist/webstats-${RELEASE_VERSION}"
TEMPLATE_DIR="release/templates"
SCRIPTS_DIR="release/scripts"

echo "📦 Creating WebStats Release v${RELEASE_VERSION}"

# Create release directories
mkdir -p "$RELEASE_DIR"/{apps/site,apps/runner,data,.github/workflows,scripts,docs,assets/screenshots,assets/icons,assets/branding}

# Copy core files
cp -r README.md LICENSE.md CONTRIBUTING.md .gitignore package.json pnpm-workspace.yaml "$RELEASE_DIR/" 2>/dev/null || true

# Copy main source code
cp -r apps/ "$RELEASE_DIR/"
cp -r .github/ "$RELEASE_DIR/"
cp -r scripts/ "$RELEASE_DIR/"
cp -r docs/ "$RELEASE_DIR/"
cp -r assets/ "$RELEASE_DIR/"

# Copy configuration
cp -r monitor.config.yml "$RELEASE_DIR/" 2>/dev/null || true

# Create release scripts
mkdir -p "$RELEASE_DIR"/release-scripts
cat > "$RELEASE_DIR/release-scripts/install.sh" << 'EOF'
#!/bin/bash
# WebStats Installation Script

echo "🚀 Installing WebStats v2025.01.15"

# Check prerequisites
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    npm install -g pnpm
fi

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Build the project
echo "⚙️ Building WebStats..."
pnpm build

# Initialize first run
echo "📡 Initializing first monitoring run..."
pnpm run runner:check

echo "✅ WebStats installed successfully!"
echo "📋 Next steps:"
echo "   1. Edit monitor.config.yml with your services"
echo "   2. Enable GitHub Actions in your repository"
echo "   3. Visit Actions tab and approve workflows"
echo "   4. Configure GitHub Pages under Settings → Pages"
EOF

cat > "$RELEASE_DIR/release-scripts/upgrade.sh" << 'EOF'
#!/bin/bash
# WebStats Upgrade Script

echo "⬆️ Upgrading WebStats"

# Backup current configuration
echo "💾 Backing up configuration..."
cp monitor.config.yml monitor.config.yml.backup

# Update dependencies
echo "📦 Updating dependencies..."
pnpm install

# Build project
echo "⚙️ Rebuilding project..."
pnpm build

# Restore configuration
echo "🔄 Restoring configuration..."
mv monitor.config.yml.backup monitor.config.yml

# Run a test check
echo "📡 Testing monitoring..."
pnpm run runner:check

echo "✅ WebStats upgraded successfully!"
EOF

cat > "$RELEASE_DIR/release-scripts/reset-data.sh" << 'EOF'
#!/bin/bash
# WebStats Data Reset Script

echo "⚠️ This will delete all monitoring data!"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ Removing monitoring data..."
    rm -rf data/checks/* data/summary/* data/incidents/*
    echo "✅ Data cleared!"
    echo "📡 Running fresh monitoring check..."
    pnpm run runner:check
else
    echo "❌ Operation cancelled."
fi
EOF

# Make scripts executable
chmod +x "$RELEASE_DIR/release-scripts/"*.sh

# Create release notes
cat > "$RELEASE_DIR/RELEASE_NOTES.md" << EOF
# WebStats v${RELEASE_VERSION} Release Notes

## ✨ What's New

- **Enhanced Terminal-Core UI**: Beautiful dark-themed interface designed for developers
- **GitHub Actions Integration**: Fully automated monitoring and deployment
- **Real-time Monitoring**: Every 5 minutes service checks with detailed statistics
- **Custom Domain Support**: Easy setup for branded status pages
- **Incident Tracking**: Automatic GitHub Issues integration
- **Historical Data**: Comprehensive uptime and response time tracking

## 🚀 Quick Start

1. **Download** this release package
2. **Extract** to your desired directory
3. **Install** dependencies: \`pnpm install\`
4. **Configure** your services in \`monitor.config.yml\`
5. **Enable** GitHub Actions in your repository
6. **Deploy** to GitHub Pages

## 🛠️ Configuration

Edit \`monitor.config.yml\` to add your services:

\`\`\`yaml
services:
  - id: your-service
    name: "Your Service Name"
    url: "https://your-service.com"
    group: "Production"
    method: "GET"
    assertions:
      status: [200]
\`\`\`

## 📋 Prerequisites

- Node.js 18+
- pnpm package manager
- GitHub account for Actions/Pages

## 🔄 Upgrade Notes

To upgrade from a previous version:
1. Backup your \`monitor.config.yml\`
2. Replace files with new release
3. Run \`pnpm install\`
4. Restore your configuration
5. Run \`pnpm build\`

## 🐛 Fixes & Improvements

- Fixed CI/CD workflow dependencies
- Enhanced error handling
- Improved data storage efficiency
- Better documentation and examples

## 🤝 Contributing

Visit our GitHub repository to contribute: https://github.com/princetheprogrammer/webstats

## 📄 License

MIT License - Free to use and modify
EOF

# Create deployment guide
cat > "$RELEASE_DIR/DEPLOYMENT_GUIDE.md" << 'EOF'
# WebStats Deployment Guide

## GitHub Repository Setup (Recommended)

### 1. Create Repository
1. Go to GitHub.com and create a new repository
2. Or use "Use this template" from the WebStats repository
3. Clone your new repository: `git clone <your-repo-url>`

### 2. Configure Services
1. Edit `monitor.config.yml` with your services to monitor
2. Set site configuration (name, description, custom domain if needed)

### 3. Enable GitHub Actions
1. Go to your repository → Actions tab
2. You'll see a message "We found workflows in your repository..."
3. Click "I understand my workflows, go ahead and run them"
4. This enables the monitoring and deployment workflows

### 4. Configure GitHub Pages
1. Go to Settings → Pages
2. Under "Source", select "GitHub Actions"
3. Your status page will automatically deploy

### 5. Custom Domain (Optional)
1. Add CNAME record to your DNS: `status.yourdomain.com → yourusername.github.io`
2. Go to Settings → Pages → Custom domain
3. Enter your custom domain
4. Check "Enforce HTTPS"

## Self-Hosting Setup

### Prerequisites
- Node.js 18+
- pnpm package manager
- Access to a web server

### 1. Install Dependencies
```bash
pnpm install
```

### 2. Build the Project
```bash
pnpm build
```

### 3. Run Monitoring
```bash
# Run a single check
pnpm run runner:check

# Run continuously (for self-hosting)
# Set up a cron job or systemd service to run every 5 minutes
```

### 4. Serve the Site
The built site is in `apps/site/dist/`. Serve it with your preferred web server.

## Docker Deployment (Future)

Coming in future releases - Docker container for easy deployment.

## Troubleshooting

### Actions Not Running
- Check Actions tab for approval prompt
- Ensure workflow permissions are set correctly
- Verify repository is public (for free tier) or has Actions enabled

### Site Not Deploying
- Check that GitHub Pages source is set to "GitHub Actions"
- Verify workflow permissions in Settings → Actions
- Look for errors in Actions logs

### Monitoring Issues
- Check that your service URLs are accessible
- Verify network connectivity from GitHub Actions runners
- Review workflow logs for specific error messages

## Monitoring Frequency

- Default: Every 5 minutes (GitHub Actions limitation)
- Configurable via `.github/workflows/monitor.yml`
- Data retention: Configurable cleanup script available

## Security

- All data stored in your repository
- No external services required
- Private repositories keep status data private
- Secure by default through GitHub's infrastructure
EOF

# Create a simple package manifest
cat > "$RELEASE_DIR/package-manifest.json" << EOF
{
  "name": "webstats-release",
  "version": "${RELEASE_VERSION}",
  "description": "WebStats monitoring platform release",
  "releaseDate": "$(date -I)",
  "contents": [
    "apps/",
    ".github/workflows/",
    "monitor.config.yml",
    "README.md",
    "LICENSE.md",
    "CONTRIBUTING.md",
    "release-scripts/",
    "docs/",
    "assets/"
  ],
  "requirements": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  },
  "installation": "pnpm install && pnpm build"
}
EOF

echo "✅ Release package created at: $RELEASE_DIR"
echo "📁 Contents:"
find "$RELEASE_DIR" -type f | sed 's/^/   /' | head -20
remaining=$(find "$RELEASE_DIR" -type f | wc -l)
if [ "$remaining" -gt 20 ]; then
    echo "   ... and $((remaining - 20)) more files"
fi

echo ""
echo "📦 To create a zip archive:"
echo "   cd $RELEASE_DIR && zip -r ../webstats-${RELEASE_VERSION}.zip ."
echo ""
echo "🔗 To create a tarball:"
echo "   cd $RELEASE_DIR && tar -czf ../webstats-${RELEASE_VERSION}.tar.gz ."