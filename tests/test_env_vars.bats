#!/usr/bin/env bats

# Tests for general CODEX_ENV_* environment variable handling

load test_helpers

@test "test_setup_script_exists_and_executable" {
    [ -f /opt/codex/setup_universal.sh ]
    [ -x /opt/codex/setup_universal.sh ]
}

@test "test_setup_script_runs_without_errors" {
    run bash -lc "source /opt/codex/setup_universal.sh"
    [ "$status" -eq 0 ]
}

@test "test_default_versions_when_no_env_vars_set" {
    # Run setup without any CODEX_ENV_* variables
    run bash -lc "unset CODEX_ENV_PYTHON_VERSION CODEX_ENV_NODE_VERSION CODEX_ENV_GO_VERSION && source /opt/codex/setup_universal.sh && python3 --version && node -v && go version"
    [ "$status" -eq 0 ]
    # Just verify commands work, don't check specific versions since defaults may vary
}

@test "test_empty_string_env_var_ignored" {
    # Empty string should be treated as unset
    run bash -lc "export CODEX_ENV_PYTHON_VERSION='' && source /opt/codex/setup_universal.sh"
    [ "$status" -eq 0 ]
    # Should not fail when empty string is provided
}
