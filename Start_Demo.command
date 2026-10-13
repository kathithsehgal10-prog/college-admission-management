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
"$node_bin" server/src/server.js &
api_pid=$!
(cd client && "$node_bin" node_modules/vite/bin/vite.js --host 127.0.0.1 --strictPort) &
ui_pid=$!
trap 'kill "$api_pid" "$ui_pid" 2>/dev/null || true' EXIT INT TERM
print 'Open http://localhost:5173. Keep this terminal open; Ctrl+C stops the demo.'
wait
