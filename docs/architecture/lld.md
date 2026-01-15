# Low Level Design (LLD)

## System Components Breakdown

### 1. Monitoring Engine (apps/runner)

#### Main Entry Point (`src/index.ts`)
- **Class**: `MonitorRunner`
- **Constructor**: Loads configuration and initializes data directories
- **Method**: `runChecks()` - orchestrates the monitoring process
- **Method**: `checkService(service)` - performs individual service check
- **Method**: `saveCheckResult(result)` - persists check results
- **Method**: `updateSummary(result)` - updates aggregated statistics
- **Method**: `handleIncidents(results)` - manages incident lifecycle

#### Configuration Loading
- **File**: `monitor.config.yml`
- **Parser**: js-yaml
- **Schema**: 
  - `site`: name, description, baseUrl, customDomain, theme
  - `monitor`: timeoutMs, retries, concurrency, userAgent
  - `services[]`: id, name, url, group, method, assertions

#### Service Check Process
1. **Initialize Request**:
   - Method: HTTP method from config (defaults to GET)
   - URL: from config
   - Timeout: from config (defaults to 8000ms)
   - Headers: User-Agent from config

2. **Execute HTTP Request**:
   - Uses axios with timeout
   - Captures response time
   - Handles network errors gracefully

3. **Validate Assertions**:
   - Status Code Validation: checks if response status matches expected values
   - Content Validation: verifies response contains expected text
   - Error Aggregation: combines assertion failures

4. **Generate Result**:
   - `id`: service identifier
   - `timestamp`: ISO timestamp of check
   - `status`: 'up' or 'down'
   - `statusCode`: HTTP status code (if available)
   - `responseTime`: Response time in milliseconds
   - `message`: Status message or error description

#### Data Persistence
- **Format**: NDJSON (Newline Delimited JSON)
- **Location**: `data/checks/{service-id}.ndjson`
- **Operation**: Append-only writes
- **Structure**: One JSON object per line

#### Summary Statistics
- **Location**: `data/summary/{service-id}.json`
- **Fields**:
  - `uptimePercentage`: (upChecks / totalChecks) * 100
  - `totalChecks`: Total number of checks performed
  - `upChecks`: Number of successful checks
  - `avgResponseTime`: Moving average of response times
  - `lastStatus`: Latest check status
  - `lastChecked`: Timestamp of last check

#### Incident Handling
- **Detection**: Status change from 'up' to 'down'
- **Tracking**: Planned for GitHub Issues integration
- **Resolution**: Status change from 'down' to 'up'

### 2. Frontend Application (apps/site)

#### Astro Configuration (`astro.config.mjs`)
- **Integrations**: 
  - `@astrojs/react`: React component support
  - `@astrojs/tailwind`: Tailwind CSS integration
- **Output**: Static site generation
- **Base**: Dynamic based on custom domain configuration

#### Layout Structure (`src/layouts/Layout.astro`)
- **Header**: Fixed navigation with "WebStats by princetheprogrammer"
- **Navigation**: Status, History, Incidents links
- **Footer**: Developer branding and platform information
- **Main Content**: Slot for page-specific content

#### Page Components

##### Home Page (`src/pages/index.astro`)
- **Data Source**: Reads from `data/summary/*.json`
- **Configuration**: Reads from `monitor.config.yml`
- **Components**: Multiple `StatusCard` components
- **Fallback**: Message when no data available

##### History Page (`src/pages/history.astro`)
- **Data Source**: Reads from `data/checks/*.ndjson`
- **Processing**: Parses NDJSON, extracts last 50 entries per service
- **Sorting**: Chronological (newest first)
- **Display**: Tabular format with sorting capabilities

##### Incidents Page (`src/pages/incidents.astro`)
- **Data Source**: Planned for `data/incidents/*.json`
- **Sample Data**: Temporary hardcoded incidents
- **Display**: Card-based layout with status indicators

#### Reusable Components

##### StatusCard (`src/components/StatusCard.astro`)
- **Props**: name, status, uptime, responseTime, lastChecked, group
- **Styling**: Terminal-core aesthetic with status-specific colors
- **Layout**: Service information, metrics grid, timestamp
- **Interactivity**: Hover effects and transitions

#### Styling (`src/styles/global.css`)
- **Framework**: Tailwind CSS with custom extensions
- **Color Palette**: Terminal-core (black, slate, cyan, indigo, violet)
- **Typography**: JetBrains Mono monospace font
- **Scrollbars**: Custom styled terminal-style scrollbars
- **Transitions**: Smooth hover and interaction effects

### 3. CI/CD Workflows

#### Monitor Workflow (`.github/workflows/monitor.yml`)
- **Trigger**: Scheduled every 5 minutes (`*/5 * * * *`)
- **Runner**: Ubuntu latest
- **Steps**:
  1. Checkout repository
  2. Setup Node.js environment
  3. Install pnpm and dependencies
  4. Run monitoring checks (`pnpm runner:check`)
  5. Generate CNAME file if custom domain configured
  6. Commit and push data changes

#### Deploy Workflow (`.github/workflows/deploy.yml`)
- **Trigger**: Push to main branch (affecting apps/site, data, or config)
- **Runner**: Ubuntu latest
- **Steps**:
  1. Checkout repository
  2. Setup Node.js and pnpm
  3. Install dependencies
  4. Generate CNAME file if custom domain configured
  5. Build Astro site (`pnpm site:build`)
  6. Deploy to GitHub Pages

#### Cleanup Workflow (`.github/workflows/cleanup.yml`)
- **Trigger**: Weekly scheduled
- **Purpose**: Prevent repository bloat by archiving old data
- **Process**: Remove check data older than 90 days
- **Retention**: Keep summary and incident data indefinitely

### 4. Data Models

#### Check Result
```typescript
interface CheckResult {
  id: string;              // Service identifier
  timestamp: number;       // Unix timestamp of check
  status: 'up' | 'down';  // Service status
  statusCode?: number;     // HTTP status code (if request succeeded)
  responseTime: number;    // Response time in milliseconds
  message: string;         // Status message or error description
}
```

#### Service Configuration
```typescript
interface ServiceConfig {
  id: string;              // Unique service identifier
  name: string;            // Display name
  url: string;             // Endpoint to monitor
  group: string;           // Service category/group
  method: string;          // HTTP method (GET, POST, etc.)
  assertions?: {           // Validation rules
    status?: number[];     // Expected status codes
    containsText?: string; // Expected response content
  };
}
```

#### Summary Data
```typescript
interface SummaryData {
  uptimePercentage: number; // Calculated uptime percentage
  totalChecks: number;      // Total number of checks performed
  upChecks: number;         // Number of successful checks
  avgResponseTime: number;  // Average response time
  lastStatus: string;       // Latest status ('up', 'down', etc.)
  lastChecked: number;      // Timestamp of last check
}
```

### 5. Build Process

#### Dependency Installation
- **Manager**: pnpm (monorepo optimized)
- **Workspaces**: apps/* pattern
- **Lockfile**: pnpm-lock.yaml for reproducible builds

#### Frontend Build
1. **Type Checking**: Astro checks component types
2. **Asset Processing**: Tailwind CSS compilation
3. **Static Generation**: Pre-render all pages
4. **Optimization**: JavaScript bundling and minification
5. **Output**: Static files in `apps/site/dist/`

#### Monitoring Build
1. **Compilation**: TypeScript to JavaScript (ES2020)
2. **Output**: JavaScript files in `apps/runner/dist/`
3. **Execution**: Node.js runtime execution

### 6. Configuration Schema

#### monitor.config.yml Structure
```yaml
site:
  name: "Site display name"
  description: "Site description"
  baseUrl: "https://user.github.io/repo"  # Or custom domain
  customDomain: "status.example.com"      # Optional
  theme:
    accent: "#06b6d4"                     # Terminal cyan
    logo: "/path/to/logo.svg"             # Optional logo

monitor:
  timeoutMs: 8000                         # Request timeout
  retries: 1                             # Retry attempts
  concurrency: 10                        # Parallel checks
  userAgent: "WebStatsBot/1.0"          # HTTP user agent

services:
  - id: "unique-identifier"
    name: "Display Name"
    url: "https://example.com"
    group: "Category"
    method: "GET"
    assertions:
      status: [200, 201]
      containsText: "expected content"
```

### 7. Error Handling

#### Network Errors
- Captured in service check process
- Recorded as 'down' status
- Error message preserved in result

#### Configuration Errors
- Handled during startup
- Graceful exit with error message
- Logged to console for debugging

#### File System Errors
- Checked before file operations
- Graceful fallback or exit
- Directory creation if missing

### 8. Performance Optimizations

#### Data Reading
- Efficient NDJSON parsing
- Limited history (last 50 entries)
- Asynchronous file operations

#### Frontend Rendering
- Static site generation
- Minimal JavaScript
- Optimized asset delivery

#### Monitoring Efficiency
- Concurrent service checks
- Configurable timeouts
- Connection pooling via axios