#!/bin/bash

# WebStats Auto Runner Setup
# This script helps automate the setup and maintenance of WebStats monitoring

set -e

echo "🚀 WebStats Auto Runner Setup"

# Function to check if running in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a git repository. Please run this from your WebStats repository."
        exit 1
    fi
}

# Function to initialize the first run
first_run() {
    echo "🔄 Performing first-time setup and run..."
    
    # Ensure data directories exist
    mkdir -p data/checks data/summary data/incidents
    
    # Run the monitoring once to generate initial data
    echo "📡 Running initial monitoring check..."
    if [ -f "apps/runner/dist/index.js" ]; then
        node apps/runner/dist/index.js
    elif [ -f "apps/runner/src/index.ts" ]; then
        echo "📦 Building runner..."
        cd apps/runner && pnpm build && cd ../..
        node apps/runner/dist/index.js
    else
        echo "❌ Runner not found. Please build first."
        exit 1
    fi
    
    echo "✅ Initial monitoring run completed"
}

# Function to setup git configuration
setup_git_config() {
    echo "🔧 Setting up git configuration..."
    
    # Configure git user if not already set
    if [ -z "$(git config user.name)" ]; then
        git config user.name "webstats-bot"
        echo "   Set git user.name to webstats-bot"
    fi
    
    if [ -z "$(git config user.email)" ]; then
        git config user.email "webstats-bot@users.noreply.github.com"
        echo "   Set git user.email to webstats-bot@users.noreply.github.com"
    fi
}

# Function to validate config file
validate_config() {
    echo "🔍 Validating configuration..."
    
    if [ ! -f "monitor.config.yml" ]; then
        echo "❌ monitor.config.yml not found!"
        exit 1
    fi
    
    # Check if config is valid YAML
    if command -v yq >/dev/null 2>&1; then
        if ! yq . < monitor.config.yml >/dev/null 2>&1; then
            echo "❌ Invalid YAML in monitor.config.yml"
            exit 1
        fi
    elif command -v node >/dev/null 2>&1; then
        if ! node -e "console.log(require('js-yaml').load(require('fs').readFileSync('monitor.config.yml', 'utf8')))" >/dev/null 2>&1; then
            echo "❌ Invalid YAML in monitor.config.yml"
            exit 1
        fi
    fi
    
    echo "✅ Configuration is valid"
}

# Function to build the project
build_project() {
    echo "🔨 Building project..."
    
    if [ -f "pnpm-lock.yaml" ]; then
        echo "📦 Installing dependencies with pnpm..."
        pnpm install
    elif [ -f "package-lock.json" ]; then
        echo "📦 Installing dependencies with npm..."
        npm install
    else
        echo "📦 Installing dependencies with yarn..."
        yarn install
    fi
    
    # Build the runner
    echo "⚙️ Building monitoring runner..."
    cd apps/runner && pnpm build && cd ../..
    
    echo "✅ Project built successfully"
}

# Function to run manual check
manual_check() {
    echo "📡 Running manual monitoring check..."
    node apps/runner/dist/index.js
    echo "✅ Manual check completed"
}

# Function to build site
build_site() {
    echo "🌐 Building status site..."
    cd apps/site && pnpm build && cd ../..
    echo "✅ Site built successfully"
}

# Function to show status
show_status() {
    echo "📊 Current monitoring status:"
    
    if [ -d "data/summary" ]; then
        echo "📈 Service summaries:"
        for file in data/summary/*.json; do
            if [ -f "$file" ]; then
                service=$(basename "$file" .json)
                status=$(jq -r '.lastStatus' "$file" 2>/dev/null || echo "unknown")
                uptime=$(jq -r '.uptimePercentage' "$file" 2>/dev/null || echo "0")
                echo "   • $service: $status (uptime: ${uptime}%)"
            fi
        done
    else
        echo "   No monitoring data available yet"
    fi
    
    echo ""
    echo "📁 Data directory structure:"
    if [ -d "data" ]; then
        find data -type f | head -10
        remaining=$(find data -type f | wc -l)
        if [ "$remaining" -gt 10 ]; then
            echo "   ... and $((remaining - 10)) more files"
        fi
    else
        echo "   Data directory not found"
    fi
}

# Function to cleanup old data
cleanup_data() {
    echo "🧹 Cleaning up old monitoring data..."
    
    # Remove check data older than 90 days
    if [ -d "data/checks" ]; then
        find data/checks -name "*.ndjson" -exec node scripts/cleanup.js \;
    fi
    
    echo "✅ Cleanup completed"
}

# Main execution
case "${1:-status}" in
    "init")
        check_git_repo
        validate_config
        setup_git_config
        build_project
        first_run
        show_status
        ;;
    "check")
        check_git_repo
        validate_config
        manual_check
        ;;
    "build")
        check_git_repo
        build_project
        build_site
        ;;
    "status")
        check_git_repo
        show_status
        ;;
    "validate")
        check_git_repo
        validate_config
        ;;
    "cleanup")
        check_git_repo
        cleanup_data
        ;;
    "auto")
        check_git_repo
        validate_config
        setup_git_config
        build_project
        first_run
        show_status
        
        echo ""
        echo "🎯 Auto setup completed!"
        echo "   • Monitoring data has been generated"
        echo "   • Site is ready to be built"
        echo "   • GitHub Actions will run every 5 minutes"
        echo "   • Remember to enable Actions in your GitHub repository"
        ;;
    *)
        echo "📖 WebStats Auto Runner"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  init      - Initialize and run first check"
        echo "  check     - Run a manual monitoring check"
        echo "  build     - Build the project"
        echo "  status    - Show current monitoring status"
        echo "  validate  - Validate configuration"
        echo "  cleanup   - Clean up old data"
        echo "  auto      - Full automated setup (recommended)"
        echo ""
        echo "Example: $0 auto"
        ;;
esac