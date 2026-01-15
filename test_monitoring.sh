#!/bin/bash

# Script to run WebStats monitoring for 5 minutes (simulate cron behavior)
echo "Starting WebStats monitoring simulation for 5 minutes..."

END_TIME=$(($(date +%s) + 300))  # 5 minutes from now

while [ $(date +%s) -lt $END_TIME ]; do
    echo "[$(date)] Running monitoring check..."
    cd /home/princetheprogrammerbtw/Projects/webstats/webstatx && node apps/runner/dist/index.js
    
    # Check results
    echo "Current status:"
    if [ -f "data/summary/homepage.json" ]; then
        echo "  Homepage: $(jq -r '.lastStatus' data/summary/homepage.json 2>/dev/null || echo 'unknown')"
    fi
    if [ -f "data/summary/api.json" ]; then
        echo "  API: $(jq -r '.lastStatus' data/summary/api.json 2>/dev/null || echo 'unknown')"
    fi
    
    echo "Sleeping for 60 seconds..."
    sleep 60
done

echo "Monitoring simulation completed!"