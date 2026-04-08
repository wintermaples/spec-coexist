#!/usr/bin/env bash
# Usage: check_doc_exists.sh <path>
# Exit 0 if file exists (signal to halt), 1 otherwise.
set -euo pipefail
path="${1:?path required}"
[ -f "$path" ]
