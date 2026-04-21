#!/bin/bash
set -e

echo "Starting EVO Auth Service..."

# Prepare database
bundle exec rails db:prepare

# Start Rails server
exec bundle exec rails s -p 3001 -b 0.0.0.0
