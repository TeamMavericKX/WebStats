# Development Documentation

## Project Setup

### Prerequisites
- Node.js (v18 or higher)
- pnpm package manager
- Git
- GitHub account (for deployment)

### Initial Setup
```bash
# Clone or use template
git clone <repository-url>
# or create from template

# Navigate to project directory
cd webstats

# Install dependencies
pnpm install
```

### Monorepo Structure
```bash
webstats/
├── apps/
│   ├── site/          # Frontend application
│   └── runner/        # Monitoring engine
├── data/              # Monitoring data
├── scripts/           # Utility scripts
├── docs/              # Documentation
├── .github/           # GitHub Actions workflows
├── monitor.config.yml # Main configuration
├── pnpm-workspace.yaml # Workspace configuration
└── package.json       # Root configuration
```

## Development Environment

### Local Development
```bash
# Start both applications in development mode
pnpm dev

# Start just the frontend
cd apps/site && pnpm dev

# Start just the runner
cd apps/runner && pnpm dev
```

### Configuration
- **Main Config**: `monitor.config.yml`
- **Frontend Config**: `apps/site/astro.config.mjs`
- **Runner Config**: `apps/runner/tsconfig.json`
- **Workspace Config**: `pnpm-workspace.yaml`

### Environment Variables
None required for local development

## Code Standards

### TypeScript Guidelines
- Use strict mode (`"strict": true`)
- Prefer interfaces over types
- Use JSDoc for exported functions/classes
- Follow naming conventions (PascalCase for classes, camelCase for functions)

### Frontend Guidelines
- Use Tailwind CSS utility classes
- Component-based architecture
- Type-safe props with Astro
- Semantic HTML elements
- Accessibility considerations

### Monitoring Engine Guidelines
- Async/await for asynchronous operations
- Error handling for network requests
- Type safety for configuration objects
- Logging for debugging purposes

## Building and Testing

### Build Process
```bash
# Build both applications
pnpm build

# Build frontend only
cd apps/site && pnpm build

# Build runner only
cd apps/runner && pnpm build
```

### Testing Strategy
```bash
# No automated tests currently (planned for future)
# Manual testing workflow:
# 1. Update monitor.config.yml with test services
# 2. Run runner locally: pnpm runner:check
# 3. Verify data generation in data/ directory
# 4. Run site locally: pnpm site:dev
# 5. Verify data display on status pages
```

### Local Testing
```bash
# Run monitoring checks locally
cd apps/runner && pnpm build
cd .. && node apps/runner/dist/index.js

# Verify data was generated
ls -la data/checks/
ls -la data/summary/
```

## Component Development

### Adding New Services
1. Edit `monitor.config.yml`
2. Add new service to `services` array
3. Configure URL, assertions, and grouping
4. Commit changes to trigger GitHub Actions

### Adding New Pages
1. Create new file in `apps/site/src/pages/`
2. Use Astro syntax and layout
3. Import necessary components
4. Add navigation link if needed

### Modifying UI Components
1. Locate component in `apps/site/src/components/`
2. Update Astro component
3. Test in development mode
4. Verify responsive behavior

### Updating Monitoring Logic
1. Modify `apps/runner/src/index.ts`
2. Update data structures if needed
3. Test locally with sample configuration
4. Verify data compatibility with frontend

## Deployment

### GitHub Pages Deployment
1. Enable GitHub Actions in repository settings
2. Configure GitHub Pages source to "GitHub Actions"
3. Push changes to main branch
4. Monitor workflow runs in Actions tab

### Custom Domain Setup
1. Configure DNS with CNAME record
2. Set custom domain in GitHub Pages settings
3. Update `monitor.config.yml` with custom domain
4. Commit changes to trigger deployment

### Workflow Triggers
- **Monitor Workflow**: Runs every 5 minutes via cron
- **Deploy Workflow**: Runs on pushes to main branch
- **Cleanup Workflow**: Runs weekly to maintain data

## Debugging

### Common Issues

#### Monitoring Not Working
- Check GitHub Actions permissions
- Verify workflow files are in `.github/workflows/`
- Ensure runner builds successfully
- Confirm service URLs are accessible

#### Frontend Not Displaying Data
- Verify data files exist in `data/` directory
- Check file permissions and formats
- Confirm Astro can read configuration
- Verify build process completes successfully

#### GitHub Actions Failing
- Check workflow syntax
- Verify permissions in workflow files
- Ensure dependencies are properly installed
- Confirm pnpm is available in runner environment

### Debugging Commands
```bash
# Check runner locally
cd apps/runner && pnpm build && cd .. && node apps/runner/dist/index.js

# Check site build
cd apps/site && pnpm build

# Verify data structure
cat data/summary/*.json
cat data/checks/*.ndjson | head -n 5

# Check configuration validity
node -e "console.log(require('js-yaml').load(require('fs').readFileSync('monitor.config.yml', 'utf8')))"
```

## Performance Optimization

### Monitoring Performance
- Optimize timeout values in config
- Adjust concurrency settings
- Group related services for efficiency
- Monitor GitHub Actions execution time

### Frontend Performance
- Minimize external dependencies
- Optimize image assets
- Use efficient data loading strategies
- Implement caching where appropriate

### Data Management
- Regular cleanup of old data
- Efficient NDJSON storage format
- Incremental data updates
- Compression for large datasets

## Version Control

### Branching Strategy
- `main`: Production-ready code
- Feature branches: New functionality
- Pull requests: Code review and testing

### Commit Messages
Follow conventional commits:
```
feat: add new monitoring service
fix: resolve data parsing issue
docs: update configuration guide
style: refactor component styling
refactor: improve monitoring logic
test: add unit tests for runner
chore: update dependencies
```

### File Organization
- Keep related files together
- Use descriptive names
- Maintain consistent structure
- Document significant changes

## Maintenance

### Regular Tasks
- Monitor GitHub Actions workflows
- Review monitoring data quality
- Update dependencies periodically
- Verify custom domain configurations

### Data Maintenance
- Weekly cleanup of old monitoring data
- Verification of data integrity
- Backup of important configurations
- Archive historical information

### Security Considerations
- Keep dependencies updated
- Review third-party integrations
- Protect sensitive configuration
- Monitor for vulnerabilities