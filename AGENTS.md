# AGENTS.md

## Cursor Cloud specific instructions

This repository is a Docker image project (`codex-universal`). There is no traditional application server, package manager lockfile, or linting/build toolchain in the repo itself — the entire product is a single `Dockerfile` that produces a multi-language development environment image.

### Prerequisites

Docker must be running. In Cloud Agent VMs (which lack systemd), start the daemon manually:

```sh
sudo containerd &>/dev/null &
sleep 2
sudo dockerd &>/dev/null &
sleep 3
```

### Build

```sh
sudo docker build -t codex-universal:test .
```

The build is heavy (~8 minutes) because it installs multiple versions of Python, Node.js, Go, Java, LLVM, Bun, Elixir/Erlang, and numerous dev tools. There is no incremental build shortcut — changes to the Dockerfile or shell scripts require a full rebuild.

### Test

```sh
# All suites
sudo docker run --rm codex-universal:test /opt/codex/run_tests.sh

# Single suite (env_vars | python_versions | node_versions | go_versions | combinations)
sudo docker run --rm codex-universal:test /opt/codex/run_tests.sh --suite=python_versions

# Verbose
sudo docker run --rm codex-universal:test /opt/codex/run_tests.sh --verbose
```

### Run (interactive)

```sh
sudo docker run --rm -it \
  -e CODEX_ENV_PYTHON_VERSION=3.12 \
  -e CODEX_ENV_NODE_VERSION=20 \
  -e CODEX_ENV_GO_VERSION=1.24.3 \
  codex-universal:test
```

### Lint

There is no separate lint step. Shell scripts are validated implicitly by the BATS tests and the `verify.sh` script that runs at build time. If you add a shell linter (e.g. `shellcheck`), run it on `*.sh` files in the repo root and `tests/*.bats`.

### Key files

| File | Purpose |
|---|---|
| `Dockerfile` | Main build definition — this IS the product |
| `setup_universal.sh` | Entrypoint helper that switches language versions based on `CODEX_ENV_*` vars |
| `entrypoint.sh` | Container entrypoint — runs setup then drops into bash |
| `verify.sh` | Build-time verification of all installed runtimes |
| `run_tests.sh` | BATS test runner |
| `tests/*.bats` | BATS test suites |

### Gotchas

- Global npm packages (codex, claude-code, etc.) are installed only on the default Node version (22). Switching to another version via `CODEX_ENV_NODE_VERSION` may not have those packages available.
- The image targets both `linux/amd64` and `linux/arm64`. OpenJDK 11 is not available on arm64. Cloud Agent VMs are amd64.
- `sudo` is required for all `docker` commands in the Cloud Agent VM since the `ubuntu` user is not in the `docker` group.
