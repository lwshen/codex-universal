#!/usr/bin/env bats

# Tests for multiple CODEX_ENV_* variables set simultaneously

load test_helpers

@test "test_all_three_languages_set" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.12 CODEX_ENV_NODE_VERSION=20 CODEX_ENV_GO_VERSION=1.24.3 && source /opt/codex/setup_universal.sh && python3 --version && node -v && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.12"* ]]
    [[ "$output" == *"v20."* ]]
    [[ "$output" == *"go1.24.3"* ]]
}

@test "test_python_and_node_only" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.13 CODEX_ENV_NODE_VERSION=22 && source /opt/codex/setup_universal.sh && python3 --version && node -v && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.13"* ]]
    [[ "$output" == *"v22."* ]]
    # Go should still work with default version
    [[ "$output" == *"go1."* ]]
}

@test "test_python_and_go_only" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.14 CODEX_ENV_GO_VERSION=1.26.0 && source /opt/codex/setup_universal.sh && python3 --version && node -v && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.14"* ]]
    [[ "$output" == *"go1.26.0"* ]]
    # Node should still work with default version
    [[ "$output" == *"v"* ]]
}

@test "test_node_and_go_only" {
    run bash -lc "export CODEX_ENV_NODE_VERSION=18 CODEX_ENV_GO_VERSION=1.22.12 && source /opt/codex/setup_universal.sh && python3 --version && node -v && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"v18."* ]]
    [[ "$output" == *"go1.22.12"* ]]
    # Python should still work with default version
    [[ "$output" == *"Python 3."* ]]
}
