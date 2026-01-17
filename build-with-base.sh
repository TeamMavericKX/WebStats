#!/bin/bash

# Extract base URL and set environment variable for build
export PUBLIC_BASE_URL=$(/home/princetheprogrammerbtw/Projects/webstats/webstatx/extract-base-url.sh)

# Run the build command
cd /home/princetheprogrammerbtw/Projects/webstats/webstatx/apps/site
npm run build