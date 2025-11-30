#!/bin/bash
# Run all validation checks for mcp-base
# This script is used by CI and can be run locally or in Docker

# Don't use set -e here - we want to track failures manually
# set -e  # Exit on any error

echo "=========================================="
echo "Running mcp-base validation checks"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any checks fail
FAILED=0

# Function to run a check and track failures
run_check() {
    local name="$1"
    shift
    echo ""
    echo -e "${YELLOW}Running: $name${NC}"
    echo "Command: $@"
    # Capture both stdout and stderr, and exit code
    if "$@" 2>&1; then
        echo -e "${GREEN}✓ $name passed${NC}"
    else
        local exit_code=$?
        echo -e "${RED}✗ $name failed (exit code: $exit_code)${NC}"
        FAILED=1
    fi
}

# 1. Black formatting check
run_check "Black formatting" poetry run black --check --diff mcp_base/ tests/

# 2. Ruff linting check
run_check "Ruff linting" poetry run ruff check mcp_base/ tests/

# 3. Pytest with coverage
run_check "Pytest with coverage" poetry run pytest --cov=mcp_base --cov-report=xml --cov-report=html --cov-report=term-missing tests/

# 4. mypy type checking
run_check "mypy type checking" poetry run mypy mcp_base/

echo ""
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Please fix the issues above.${NC}"
    exit 1
fi

