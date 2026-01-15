# High Level Design (HLD)

## System Overview

WebStats is a distributed monitoring system that leverages GitHub's ecosystem to provide uptime monitoring without infrastructure requirements. The system consists of three main components: the monitoring engine, data storage, and the frontend presentation layer.

## Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub      │    │   WebStats      │    │   End Users     │
│   Actions     │────│   Monitoring    │────│   (Browser)     │
│   (Scheduler) │    │   Engine        │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                            │
                            │ (NDJSON data)
                            ▼
                    ┌──────────────────┐
                    │   Git Repo      │
                    │   (Data Store)  │
                    └──────────────────┘
                            │
                            │ (Static Site)
                            ▼
                    ┌──────────────────┐
                    │   GitHub Pages  │
                    │   (Frontend)    │
                    └──────────────────┘
```

## Core Components

### 1. Monitoring Engine (Runner)
- **Purpose**: Performs HTTP checks on configured services
- **Location**: apps/runner
- **Technology**: Node.js, TypeScript
- **Responsibilities**:
  - Executes HTTP requests to monitor endpoints
  - Validates response against configured assertions
  - Records check results to data files
  - Calculates and updates summary statistics
  - Detects and reports incidents

### 2. Data Layer
- **Purpose**: Stores monitoring results and metadata
- **Technology**: NDJSON files in Git repository
- **Structure**:
  - `data/checks/`: Individual check results in chronological order
  - `data/summary/`: Aggregated statistics per service
  - `data/incidents/`: Incident tracking and resolution data
- **Characteristics**:
  - Append-only for performance
  - Human-readable format
  - Version-controlled storage

### 3. Frontend Presentation
- **Purpose**: Displays status information to users
- **Location**: apps/site
- **Technology**: Astro, React, Tailwind CSS
- **Responsibilities**:
  - Renders service status cards
  - Displays historical data
  - Shows incident information
  - Provides navigation and user experience

### 4. Infrastructure Layer
- **GitHub Actions**: Provides scheduling and execution environment
- **Git Repository**: Stores code, configuration, and monitoring data
- **GitHub Pages**: Hosts the frontend for public access
- **GitHub Issues**: Tracks incidents and problems

## Data Flow

### Monitoring Cycle
1. GitHub Actions triggers monitoring workflow
2. Runner reads configuration from `monitor.config.yml`
3. Runner executes HTTP checks for all configured services
4. Results are appended to NDJSON files in `data/checks/`
5. Summary statistics are updated in `data/summary/`
6. Incidents are tracked in `data/incidents/`
7. Data files are committed back to the repository
8. GitHub Actions triggers site deployment
9. Astro builds static site using latest data
10. GitHub Pages serves updated status page

### User Interaction
1. User visits status page hosted on GitHub Pages
2. Browser loads static site with embedded data
3. User navigates between status, history, and incidents views
4. Data is rendered from NDJSON files converted to JSON during build

## Security Model

### Authentication
- No authentication required for status viewing
- GitHub authentication required for configuration changes
- GitHub Actions tokens for automated operations

### Authorization
- Repository access controls determine who can modify configuration
- GitHub Pages provides public read access
- Private repositories keep status data private

### Data Protection
- All data stored in Git repository with full history
- NDJSON format prevents injection attacks
- Input validation in monitoring engine
- Sanitized output in frontend templates

## Scalability Considerations

### Horizontal Scaling
- Additional services configured in `monitor.config.yml`
- No infrastructure changes needed
- Limited by GitHub Actions execution time

### Data Volume
- NDJSON format supports large datasets efficiently
- Cleanup workflows prevent repository bloat
- Historical data aggregation reduces storage needs

### Performance
- Static site generation ensures fast load times
- CDN distribution through GitHub Pages
- Caching strategies for optimal performance

## Integration Points

### GitHub Ecosystem
- GitHub Actions for scheduling and execution
- GitHub Pages for hosting
- GitHub Issues for incident tracking
- GitHub API for automation

### External Systems
- HTTP endpoints for monitoring
- DNS providers for custom domains
- Notification systems (planned future feature)

## Constraints and Limitations

### GitHub Actions Limits
- Execution time limits (6 hours maximum)
- Concurrent job limits
- Rate limits for API calls

### GitHub Pages Constraints
- Static site only (no server-side processing)
- Size limits (1GB per site)
- Custom domain requirements

### Monitoring Frequency
- Minimum 5-minute intervals for scheduled runs
- Dependent on GitHub Actions availability
- No real-time alerting (planned for future)

## Deployment Model

### Template Repository
- Users create repository from template
- Single configuration file setup
- Automated GitHub Actions workflows
- Zero-infrastructure deployment

### Configuration-Driven
- All monitoring setup via `monitor.config.yml`
- Theme and customization options available
- Custom domain support through configuration
- Extensible monitoring rules