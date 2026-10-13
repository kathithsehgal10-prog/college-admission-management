#!/bin/zsh
set -e
cd "$(dirname "$0")"
node_bin="$(command -v node || true)"
if [[ -z "$node_bin" ]]; then
  node_bin="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node"
fi
if [[ ! -x "$node_bin" ]]; then
  print 'Install Node.js 20.19+ first.'
  read 'reply?Press Enter to close.'
  exit 1
fi
"$node_bin" server/src/scripts/provisionProject.js
"$node_bin" server/src/scripts/checkDatabase.js
read 'reply?Setup finished. Press Enter to close.'
