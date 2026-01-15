#!/usr/bin/env bash

# Test helper functions for CODEX_ENV_* variable testing

# Setup function to initialize test environment
setup_test_environment() {
    # Source profile to load pyenv, nvm, mise
    if [ -f /etc/profile ]; then
        source /etc/profile
    fi

    # Ensure mise is activated
    if command -v mise &> /dev/null; then
        export PATH="$HOME/.local/share/mise/shims:$PATH"
        eval "$(mise activate bash)"
    fi
}

# Run setup_universal.sh with specific environment variables
run_setup_with_env() {
    local env_vars="$1"
    bash -lc "$env_vars source /opt/codex/setup_universal.sh"
}

# Get current Python version from pyenv
get_current_python_version() {
    bash -lc "pyenv version" | awk '{print $1}'
}

# Get current Node.js version
get_current_node_version() {
    bash -lc "node -v"
}

# Get current Go version
get_current_go_version() {
    bash -lc "go version" | awk '{print $3}'
}

# Assert that a version string contains expected substring
assert_version_contains() {
    local actual="$1"
    local expected="$2"

    if [[ "$actual" == *"$expected"* ]]; then
        return 0
    else
        echo "Expected version to contain '$expected', got '$actual'"
        return 1
    fi
}

# Assert that a command is available
assert_command_available() {
    local cmd="$1"
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        echo "Command '$cmd' not found"
        return 1
    fi
}

# Check if setup script exists
assert_setup_script_exists() {
    if [ -f /opt/codex/setup_universal.sh ]; then
        return 0
    else
        echo "Setup script /opt/codex/setup_universal.sh not found"
        return 1
    fi
}
