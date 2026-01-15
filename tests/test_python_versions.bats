#!/usr/bin/env bats

# Tests for Python version switching via CODEX_ENV_PYTHON_VERSION

load test_helpers

@test "test_python_3_10_switching" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.10 && source /opt/codex/setup_universal.sh && python3 --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.10"* ]]
}

@test "test_python_3_11_12_switching" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.11.12 && source /opt/codex/setup_universal.sh && python3 --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.11.12"* ]]
}

@test "test_python_3_12_switching" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.12 && source /opt/codex/setup_universal.sh && python3 --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.12"* ]]
}

@test "test_python_3_13_switching" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.13 && source /opt/codex/setup_universal.sh && python3 --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.13"* ]]
}

@test "test_python_3_14_switching" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.14 && source /opt/codex/setup_universal.sh && python3 --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.14"* ]]
}

@test "test_python_pyenv_global_updated" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.12 && source /opt/codex/setup_universal.sh && pyenv version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"3.12"* ]]
}

@test "test_python_pip_available_after_switch" {
    run bash -lc "export CODEX_ENV_PYTHON_VERSION=3.13 && source /opt/codex/setup_universal.sh && pip --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"python 3.13"* ]]
}
