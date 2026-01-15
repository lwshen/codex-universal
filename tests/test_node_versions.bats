#!/usr/bin/env bats

# Tests for Node.js version switching via CODEX_ENV_NODE_VERSION

load test_helpers

@test "test_node_18_switching" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=18 && source /opt/codex/setup_universal.sh && node -v"
    [ "$status" -eq 0 ]
    [[ "$output" == *"v18."* ]]
}

@test "test_node_20_switching" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=20 && source /opt/codex/setup_universal.sh && node -v"
    [ "$status" -eq 0 ]
    [[ "$output" == *"v20."* ]]
}

@test "test_node_22_switching" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=22 && source /opt/codex/setup_universal.sh && node -v"
    [ "$status" -eq 0 ]
    [[ "$output" == *"v22."* ]]
}

@test "test_node_24_switching" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=24 && source /opt/codex/setup_universal.sh && node -v"
    [ "$status" -eq 0 ]
    [[ "$output" == *"v24."* ]]
}

@test "test_node_nvm_alias_updated" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=20 && source /opt/codex/setup_universal.sh && nvm alias default"
    [ "$status" -eq 0 ]
    [[ "$output" == *"20"* ]]
}

@test "test_node_npm_available_after_switch" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=20 && source /opt/codex/setup_universal.sh && npm --version"
    [ "$status" -eq 0 ]
    # Just verify npm is available and returns a version
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "test_node_corepack_enabled" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=22 && source /opt/codex/setup_universal.sh && yarn --version"
    [ "$status" -eq 0 ]
    # Verify yarn works (corepack enables it)
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]
}
