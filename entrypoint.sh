#!/bin/bash

echo "=================================="
echo "Welcome to openai/codex-universal!"
echo "=================================="

/opt/codex/setup_universal.sh

echo "Environment ready. Dropping you into a bash shell."
if [ "$#" -eq 0 ]; then
  exec bash --login
else
  exec bash --login -c 'exec "$@"' bash "$@"
fi
