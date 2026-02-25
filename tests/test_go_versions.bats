#!/usr/bin/env bats

# Tests for Go version switching via CODEX_ENV_GO_VERSION

load test_helpers

@test "test_go_1_22_12_switching" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.22.12 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.22.12"* ]]
}

@test "test_go_1_23_8_switching" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.23.8 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.23.8"* ]]
}

@test "test_go_1_24_3_switching" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.24.3 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.24.3"* ]]
}

@test "test_go_1_25_1_switching" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.25.1 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.25.1"* ]]
}

@test "test_go_1_26_0_switching" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.26.0 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.26.0"* ]]
}

@test "test_go_mise_current_updated" {
    run bash -lc "export CODEX_ENV_GO_VERSION=1.24.3 && source /opt/codex/setup_universal.sh && mise current go"
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.24.3"* ]]
}

@test "test_go_only_switches_if_different" {
    # First, switch to a specific version
    run bash -lc "export CODEX_ENV_GO_VERSION=1.23.8 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]

    # Now run setup again with the same version and verify it still works
    run bash -lc "export CODEX_ENV_GO_VERSION=1.23.8 && source /opt/codex/setup_universal.sh && go version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.23.8"* ]]
}
