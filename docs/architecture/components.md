# System Components

## Component Architecture

WebStats follows a modular monorepo architecture with clear separation of concerns between monitoring, data storage, and presentation layers.

## Core Components

### 1. Monitoring Engine (`apps/runner`)

#### Purpose
The monitoring engine is responsible for performing HTTP checks on configured services and recording the results.

#### Structure
```
apps/runner/
├── src/
│   └── index.ts              # Main application entry point
├── package.json             # Dependencies and scripts
├── tsconfig.json           # TypeScript configuration
└── README.md              # Runner documentation
```

#### Key Classes
- **`MonitorRunner`**: Main class that orchestrates monitoring
- **`MonitorConfig`**: Configuration interface
- **`CheckResult`**: Result data structure
- **`ServiceConfig`**: Service configuration interface

#### Responsibilities
- Execute HTTP requests to monitor endpoints
- Validate responses against configured assertions
- Record check results to data files
- Calculate and update summary statistics
- Handle incident detection and reporting

### 2. Frontend Application (`apps/site`)

#### Purpose
The frontend application provides a user interface to display monitoring data and status information.

#### Structure
```
apps/site/
├── src/
│   ├── components/          # Reusable UI components
│   │   └── StatusCard.astro
│   ├── layouts/            # Page layouts
│   │   └── Layout.astro
│   ├── pages/              # Route-specific pages
│   │   ├── index.astro
│   │   ├── history.astro
│   │   └── incidents.astro
│   ├── styles/             # Global styles
│   │   └── global.css
│   └── config.ts           # Site configuration
├── astro.config.mjs        # Astro configuration
├── package.json            # Dependencies and scripts
├── tailwind.config.js      # Tailwind CSS configuration
└── tsconfig.json          # TypeScript configuration
```

#### Key Components
- **`Layout.astro`**: Base layout with header, navigation, and footer
- **`StatusCard.astro`**: Service status display component
- **`index.astro`**: Main status page
- **`history.astro`**: Check history page
- **`incidents.astro`**: Incident tracking page

#### Responsibilities
- Render service status information
- Display historical monitoring data
- Present incident information
- Provide navigation between views

### 3. Data Layer (`data/`)

#### Purpose
The data layer stores all monitoring results, summaries, and incident information in a structured format.

#### Structure
```
data/
├── checks/                 # Individual check results (NDJSON)
│   ├── google.ndjson
│   ├── discord.ndjson
│   ├── cloudflare.ndjson
│   └── ...
├── summary/               # Aggregated statistics (JSON)
│   ├── google.json
│   ├── discord.json
│   ├── cloudflare.json
│   └── ...
└── incidents/             # Incident tracking data (JSON)
    └── incidents.json
```

#### Responsibilities
- Store raw monitoring data
- Maintain aggregated statistics
- Track incident history
- Provide data for frontend rendering

### 4. Configuration (`monitor.config.yml`)

#### Purpose
Centralized configuration for all aspects of the monitoring system.

#### Structure
```yaml
site:                      # Site configuration
  name: "WebStats"
  description: "..."
  baseUrl: "..."
  customDomain: "..."
  theme: {...}

monitor:                   # Monitoring engine configuration
  timeoutMs: 8000
  retries: 1
  concurrency: 10
  userAgent: "..."

services:                  # Monitored services
  - id: "..."
    name: "..."
    url: "..."
    group: "..."
    method: "..."
    assertions: {...}
```

#### Responsibilities
- Define monitored services
- Configure monitoring behavior
- Set site presentation options
- Specify custom domain settings

### 5. CI/CD Workflows (`.github/workflows/`)

#### Purpose
Automated workflows for monitoring, deployment, and maintenance tasks.

#### Structure
```
.github/workflows/
├── monitor.yml            # Scheduled monitoring
├── deploy.yml             # Site deployment
└── cleanup.yml            # Data maintenance
```

#### Key Workflows
- **`monitor.yml`**: Executes monitoring checks every 5 minutes
- **`deploy.yml`**: Builds and deploys site when data changes
- **`cleanup.yml`**: Archives old monitoring data weekly

#### Responsibilities
- Schedule and execute monitoring
- Deploy updated status pages
- Maintain data storage efficiency
- Handle custom domain configuration

### 6. Scripts (`scripts/`)

#### Purpose
Utility scripts for maintenance and administrative tasks.

#### Structure
```
scripts/
└── cleanup.js             # Data cleanup utility
```

#### Responsibilities
- Archive old monitoring data
- Maintain repository size
- Perform routine maintenance tasks

## Integration Points

### Data Flow Between Components
1. **Monitoring Engine** → **Data Layer**: Writes check results and summaries
2. **Data Layer** → **Frontend**: Provides data for page generation
3. **Configuration** → **Monitoring Engine**: Specifies services to monitor
4. **Configuration** → **Frontend**: Defines site appearance
5. **CI/CD Workflows** → **All Components**: Orchestrates automated operations

### Interface Contracts

#### Data Layer Interface
- **Input**: Raw check results from monitoring engine
- **Output**: Structured data for frontend consumption
- **Format**: NDJSON for checks, JSON for summaries
- **Location**: `data/` directory

#### Configuration Interface
- **Input**: User-defined settings in YAML
- **Output**: Runtime configuration objects
- **Format**: YAML → JavaScript objects
- **Location**: `monitor.config.yml`

#### API Contract
- **Monitoring Engine**: Reads config, writes data
- **Frontend**: Reads data, reads config
- **CI/CD**: Invokes executables, manages files

## Component Dependencies

### External Dependencies
- **Monitoring Engine**:
  - `axios`: HTTP requests
  - `js-yaml`: Configuration parsing
  - `fs-extra`: File system operations
  - `ndjson`: Data serialization
- **Frontend**:
  - `astro`: Static site generation
  - `react`: Component framework
  - `tailwindcss`: Styling framework

### Internal Dependencies
- **Monitoring Engine** ↔ **Data Layer**: Direct file I/O
- **Frontend** ↔ **Data Layer**: Build-time data access
- **All** ↔ **Configuration**: Runtime configuration access

## Component Lifecycle

### Initialization
1. **Configuration** loaded first
2. **Monitoring Engine** initialized with config
3. **Data Layer** directories prepared
4. **Frontend** build accesses data and config

### Runtime
1. **Monitoring Engine** executes checks
2. **Data Layer** receives and stores results
3. **Frontend** renders with latest data
4. **CI/CD** orchestrates the process

### Maintenance
1. **Cleanup Scripts** archive old data
2. **CI/CD** executes maintenance tasks
3. **Data Layer** optimized for storage
4. **Frontend** continues serving current data

## Component Testing Strategy

### Monitoring Engine
- Unit tests for HTTP request logic
- Mock tests for configuration loading
- Integration tests for data persistence

### Frontend
- Component tests for UI elements
- Integration tests for data consumption
- Visual regression tests for UI consistency

### Data Layer
- Format validation tests
- Performance tests for large datasets
- Migration tests for schema changes