import axios, { AxiosResponse } from 'axios';
import fs from 'fs-extra';
import path from 'path';
import yaml from 'js-yaml';
import ndjson from 'ndjson';

interface ServiceConfig {
  id: string;
  name: string;
  url: string;
  group: string;
  method: string;
  assertions?: {
    status?: number[];
    containsText?: string;
  };
}

interface MonitorConfig {
  site: {
    name: string;
    description: string;
    baseUrl: string;
    customDomain?: string;
    theme: {
      accent: string;
      logo: string;
    };
  };
  monitor: {
    timeoutMs: number;
    retries: number;
    concurrency: number;
    userAgent: string;
  };
  services: ServiceConfig[];
}

interface CheckResult {
  id: string;
  timestamp: number;
  status: 'up' | 'down';
  statusCode?: number;
  responseTime?: number;
  message?: string;
}

class MonitorRunner {
  private config: MonitorConfig;
  private dataDir = path.join(process.cwd(), 'data');

  constructor() {
    // Look for config in the project root (where package.json is located)
    const configPath = path.join(__dirname, '..', '..', '..', 'monitor.config.yml');
    const configFile = fs.readFileSync(configPath, 'utf8');
    this.config = yaml.load(configFile) as MonitorConfig;
    
    // Ensure data directory exists
    fs.ensureDirSync(this.dataDir);
    fs.ensureDirSync(path.join(this.dataDir, 'checks'));
    fs.ensureDirSync(path.join(this.dataDir, 'summary'));
    fs.ensureDirSync(path.join(this.dataDir, 'incidents'));
  }

  async runChecks(): Promise<void> {
    console.log(`Starting monitoring checks for ${this.config.services.length} services...`);
    
    const promises = this.config.services.map(service => this.checkService(service));
    const results = await Promise.all(promises);
    
    // Process results and save data
    for (const result of results) {
      await this.saveCheckResult(result);
      await this.updateSummary(result);
    }
    
    // Handle incidents
    await this.handleIncidents(results);
    
    console.log('Monitoring checks completed.');
  }

  private async checkService(service: ServiceConfig): Promise<CheckResult> {
    const startTime = Date.now();
    
    try {
      const response: AxiosResponse = await axios({
        method: service.method || 'GET',
        url: service.url,
        timeout: this.config.monitor.timeoutMs,
        headers: {
          'User-Agent': this.config.monitor.userAgent
        }
      });
      
      const responseTime = Date.now() - startTime;
      const statusCode = response.status;
      
      // Validate assertions
      let isUp = true;
      let message = 'OK';
      
      if (service.assertions?.status && !service.assertions.status.includes(statusCode)) {
        isUp = false;
        message = `Expected status ${service.assertions.status.join(', ')}, got ${statusCode}`;
      }
      
      if (isUp && service.assertions?.containsText && !response.data.includes(service.assertions.containsText)) {
        isUp = false;
        message = `Response does not contain expected text: ${service.assertions.containsText}`;
      }
      
      return {
        id: service.id,
        timestamp: Date.now(),
        status: isUp ? 'up' : 'down',
        statusCode,
        responseTime,
        message
      };
    } catch (error: any) {
      const responseTime = Date.now() - startTime;
      return {
        id: service.id,
        timestamp: Date.now(),
        status: 'down',
        responseTime,
        message: error.message || 'Request failed'
      };
    }
  }

  private async saveCheckResult(result: CheckResult): Promise<void> {
    const filePath = path.join(this.dataDir, 'checks', `${result.id}.ndjson`);
    const writeStream = fs.createWriteStream(filePath, { flags: 'a' });
    writeStream.write(JSON.stringify(result) + '\n');
    writeStream.end();
  }

  private async updateSummary(result: CheckResult): Promise<void> {
    const summaryPath = path.join(this.dataDir, 'summary', `${result.id}.json`);
    
    let summary: any = { uptimePercentage: 0, totalChecks: 0, upChecks: 0, avgResponseTime: 0, lastStatus: 'unknown' };
    
    if (fs.existsSync(summaryPath)) {
      summary = JSON.parse(fs.readFileSync(summaryPath, 'utf8'));
    }
    
    summary.totalChecks += 1;
    if (result.status === 'up') {
      summary.upChecks += 1;
    }
    
    if (result.responseTime !== undefined) {
      // Calculate moving average for response time
      const totalResponseTime = (summary.avgResponseTime * (summary.totalChecks - 1)) + result.responseTime;
      summary.avgResponseTime = totalResponseTime / summary.totalChecks;
    }
    
    summary.lastStatus = result.status;
    summary.lastChecked = result.timestamp;
    summary.uptimePercentage = (summary.upChecks / summary.totalChecks) * 100;
    
    fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
  }

  private async handleIncidents(results: CheckResult[]): Promise<void> {
    // This would handle creating/closing GitHub issues for incidents
    // For now, we'll just log incidents
    for (const result of results) {
      if (result.status === 'down') {
        console.log(`INCIDENT: Service ${result.id} is down - ${result.message}`);
        // In a real implementation, this would create a GitHub issue
      }
    }
  }
}

async function main(): Promise<void> {
  const runner = new MonitorRunner();
  try {
    await runner.runChecks();
  } catch (error) {
    console.error('Monitoring failed:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}