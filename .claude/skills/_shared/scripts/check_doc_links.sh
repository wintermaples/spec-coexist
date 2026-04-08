#!/usr/bin/env bash
# check_doc_links.sh — thin wrapper around check_doc_links.py
# Usage: check_doc_links.sh [--root docs] [--strict] [--json]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
exec python3 "$here/check_doc_links.py" "$@"
