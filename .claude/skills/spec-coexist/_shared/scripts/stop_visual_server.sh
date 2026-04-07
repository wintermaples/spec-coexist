#!/usr/bin/env bash
# Usage: stop_visual_server.sh <pid>
set -euo pipefail
pid="${1:?pid required}"
kill "$pid" 2>/dev/null || true
