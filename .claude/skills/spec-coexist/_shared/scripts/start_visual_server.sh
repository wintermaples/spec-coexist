#!/usr/bin/env bash
# Usage: start_visual_server.sh <project-dir> [--host 127.0.0.1] [--port 0] [--url-host localhost]
# Backgrounds the visual_server.py process and prints the JSON it emits on its
# first line of stdout (which contains the URL, screen_dir, and state_dir).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
project="${1:?project-dir required}"
shift || true
log="$(mktemp -t spec-coexist-visual.XXXXXX.log)"
nohup python3 "$here/visual_server.py" --project-dir "$project" "$@" >"$log" 2>&1 &
pid=$!
# Wait up to 5s for the first JSON line
for _ in $(seq 1 50); do
  if [ -s "$log" ]; then
    line="$(head -n1 "$log")"
    case "$line" in
      \{*) echo "$line"; echo "pid=$pid"; echo "log=$log"; exit 0 ;;
    esac
  fi
  sleep 0.1
done
echo "failed to start visual server; see $log" >&2
kill "$pid" 2>/dev/null || true
exit 1
