"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const axios_1 = __importDefault(require("axios"));
const fs_extra_1 = __importDefault(require("fs-extra"));
const path_1 = __importDefault(require("path"));
const js_yaml_1 = __importDefault(require("js-yaml"));
class MonitorRunner {
    constructor() {
        this.dataDir = path_1.default.join(process.cwd(), 'data');
        // Look for config in the project root (where package.json is located)
        const configPath = path_1.default.join(__dirname, '..', '..', '..', 'monitor.config.yml');
        const configFile = fs_extra_1.default.readFileSync(configPath, 'utf8');
        this.config = js_yaml_1.default.load(configFile);
        // Ensure data directory exists
        fs_extra_1.default.ensureDirSync(this.dataDir);
        fs_extra_1.default.ensureDirSync(path_1.default.join(this.dataDir, 'checks'));
        fs_extra_1.default.ensureDirSync(path_1.default.join(this.dataDir, 'summary'));
        fs_extra_1.default.ensureDirSync(path_1.default.join(this.dataDir, 'incidents'));
    }
    async runChecks() {
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
    async checkService(service) {
        const startTime = Date.now();
        try {
            const response = await (0, axios_1.default)({
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
        }
        catch (error) {
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
    async saveCheckResult(result) {
        const filePath = path_1.default.join(this.dataDir, 'checks', `${result.id}.ndjson`);
        const writeStream = fs_extra_1.default.createWriteStream(filePath, { flags: 'a' });
        writeStream.write(JSON.stringify(result) + '\n');
        writeStream.end();
    }
    async updateSummary(result) {
        const summaryPath = path_1.default.join(this.dataDir, 'summary', `${result.id}.json`);
        let summary = { uptimePercentage: 0, totalChecks: 0, upChecks: 0, avgResponseTime: 0, lastStatus: 'unknown' };
        if (fs_extra_1.default.existsSync(summaryPath)) {
            summary = JSON.parse(fs_extra_1.default.readFileSync(summaryPath, 'utf8'));
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
        fs_extra_1.default.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
    }
    async handleIncidents(results) {
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
async function main() {
    const runner = new MonitorRunner();
    try {
        await runner.runChecks();
    }
    catch (error) {
        console.error('Monitoring failed:', error);
        process.exit(1);
    }
}
if (require.main === module) {
    main();
}
