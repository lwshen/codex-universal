#!/bin/bash
set -euo pipefail

CODEX_USER=${CODEX_USER:-codex}

if [ "$(id -u)" -eq 0 ] && [ "${CODEX_USER}" != "root" ]; then
    exec sudo -E -H -u "${CODEX_USER}" CODEX_USER="${CODEX_USER}" CODEX_HOME="${CODEX_HOME:-/opt/codex}" "$0" "$@"
fi

echo "=================================="
echo "Welcome to openai/codex-universal!"
echo "=================================="

/opt/codex/setup_universal.sh

echo "Environment ready. Dropping you into a bash shell (${CODEX_USER})."
exec bash --login "$@"
