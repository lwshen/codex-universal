#!/bin/bash

set -euo pipefail

export CODEX_HOME="${CODEX_HOME:-/opt/codex}"
export HOME="${CODEX_HOME}"

if [ -f /etc/profile ]; then
    # shellcheck disable=SC1091
    source /etc/profile
fi

# Activate mise for language runtime management
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(mise activate bash)"

echo "Verifying language runtimes ..."

echo "- Python:"
python3 --version
pyenv versions | sed 's/^/  /'

echo "- Node.js:"
for version in "18" "20" "22"; do
    nvm use --global "${version}"
    node --version
    npm --version
    pnpm --version
    yarn --version
    npm ls -g
done

echo "- Bun:"
bun --version

echo "- Java / Gradle:"
java -version
javac -version
gradle --version | head -n 3
mvn --version | head -n 1

echo "- Go:"
go version

echo "- Elixir:"
elixir --version
erl -version
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell

# echo "- Codex:"
# codex --version

echo "All language runtimes detected successfully."
