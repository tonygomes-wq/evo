#!/bin/bash

# Script to run tenant isolation tests
# Usage: ./scripts/run_tenant_isolation_tests.sh

set -e

echo "========================================="
echo "Tenant Isolation Tests"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if test database exists
echo "Checking test database..."
if ! psql -h localhost -U postgres -lqt | cut -d \| -f 1 | grep -qw evo_core_test; then
    echo -e "${YELLOW}Test database not found. Creating evo_core_test...${NC}"
    createdb -h localhost -U postgres evo_core_test
    echo -e "${GREEN}✓ Test database created${NC}"
else
    echo -e "${GREEN}✓ Test database exists${NC}"
fi

echo ""

# Run migrations on test database
echo "Running migrations on test database..."
migrate -path ./migrations -database "postgresql://postgres:postgres@localhost:5432/evo_core_test?sslmode=disable" up
echo -e "${GREEN}✓ Migrations applied${NC}"

echo ""

# Run tests
echo "Running tenant isolation tests..."
echo ""

# Agent repository tests
echo "Testing: pkg/agent/repository"
go test -v ./pkg/agent/repository -run TestTenantIsolation

echo ""

# Custom tool repository tests (if exists)
if [ -f "./pkg/custom_tool/repository/custom_tool_repository_test.go" ]; then
    echo "Testing: pkg/custom_tool/repository"
    go test -v ./pkg/custom_tool/repository -run TestTenantIsolation
    echo ""
fi

# API key repository tests (if exists)
if [ -f "./pkg/api_key/repository/api_key_repository_test.go" ]; then
    echo "Testing: pkg/api_key/repository"
    go test -v ./pkg/api_key/repository -run TestTenantIsolation
    echo ""
fi

# Folder repository tests (if exists)
if [ -f "./pkg/folder/repository/folder_repository_test.go" ]; then
    echo "Testing: pkg/folder/repository"
    go test -v ./pkg/folder/repository -run TestTenantIsolation
    echo ""
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tenant isolation tests completed!${NC}"
echo "========================================="
