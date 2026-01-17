#!/bin/bash

# Extract base URL from monitor.config.yml for local development
# Use absolute path to config file
CONFIG_FILE="/home/princetheprogrammerbtw/Projects/webstats/webstatx/monitor.config.yml"

BASE_URL=$(grep -A 10 "site:" "$CONFIG_FILE" | grep "baseUrl:" | head -1 | sed 's/.*baseUrl:[[:space:]]*"\?\([^"]*\)"\?.*/\1/')

# Extract pathname from full URL for base configuration
BASE_PATH=$(echo "$BASE_URL" | sed 's|https://[^/]*/||' | sed 's|/$||')

if [ "$BASE_PATH" = "" ]; then
  BASE_PATH="/"
else
  BASE_PATH="/$BASE_PATH"
fi

echo "$BASE_PATH"