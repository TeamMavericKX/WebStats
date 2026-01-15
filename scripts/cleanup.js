#!/usr/bin/env node

/**
 * Data cleanup script
 * This script cleans up old monitoring data to prevent repository bloat
 */

const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data', 'checks');
const RETENTION_DAYS = 90;
const NOW = Date.now();

console.log('Starting data cleanup...');

// Clean up old check files
if (fs.existsSync(DATA_DIR)) {
  const files = fs.readdirSync(DATA_DIR);
  
  for (const file of files) {
    if (file.endsWith('.ndjson')) {
      console.log(`Processing ${file}...`);
      
      const filePath = path.join(DATA_DIR, file);
      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.trim().split('\n').filter(line => line);
      
      // Parse all records
      const records = lines.map(line => {
        try {
          return JSON.parse(line);
        } catch (e) {
          return null;
        }
      }).filter(Boolean);
      
      // Filter records to keep only recent ones
      const cutoffDate = NOW - (RETENTION_DAYS * 24 * 60 * 60 * 1000);
      const recentRecords = records.filter(record => record.timestamp > cutoffDate);
      
      if (recentRecords.length < records.length) {
        console.log(`  Removed ${records.length - recentRecords.length} old records from ${file}`);
        
        // Write back the recent records
        const newContent = recentRecords.map(record => JSON.stringify(record)).join('\n') + '\n';
        fs.writeFileSync(filePath, newContent);
      }
    }
  }
}

console.log('Data cleanup completed.');