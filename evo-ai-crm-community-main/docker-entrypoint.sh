#!/bin/bash
set -e

echo "Starting EVO CRM Service..."

# Prepare database
bundle exec rails db:prepare

# Start Rails server
exec bundle exec rails s -p 3000 -b 0.0.0.0
