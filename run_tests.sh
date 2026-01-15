#!/bin/bash --login

set -euo pipefail

# Test runner script for CODEX_ENV_* variable tests
# Usage: ./run_tests.sh [options]
# Options:
#   --suite=<name>    Run specific test suite (env_vars|python|node|go|combinations)
#   --verbose         Show verbose output
#   --report=<format> Generate report (junit)

SUITE=""
VERBOSE=""
REPORT=""
TEST_DIR="/opt/codex/tests"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --suite=*)
            SUITE="${arg#*=}"
            shift
            ;;
        --verbose)
            VERBOSE="--verbose-run"
            shift
            ;;
        --report=*)
            REPORT="${arg#*=}"
            shift
            ;;
        *)
            # Unknown option
            ;;
    esac
done

# Source profile to ensure pyenv, nvm, mise are available
if [ -f /etc/profile ]; then
    source /etc/profile
fi

# Ensure mise is activated
if command -v mise &> /dev/null; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    eval "$(mise activate bash)"
fi

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: bats is not installed"
    exit 1
fi

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "Error: Test directory $TEST_DIR not found"
    exit 1
fi

echo "Running CODEX_ENV_* variable tests..."
echo ""

# Determine which tests to run
if [ -n "$SUITE" ]; then
    TEST_FILE="$TEST_DIR/test_${SUITE}.bats"
    if [ ! -f "$TEST_FILE" ]; then
        echo "Error: Test suite '$SUITE' not found at $TEST_FILE"
        exit 1
    fi
    echo "Running test suite: $SUITE"
    bats $VERBOSE "$TEST_FILE"
else
    echo "Running all test suites..."
    bats $VERBOSE "$TEST_DIR"/*.bats
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✓ All tests passed!"
else
    echo ""
    echo "✗ Some tests failed"
fi

exit $EXIT_CODE
