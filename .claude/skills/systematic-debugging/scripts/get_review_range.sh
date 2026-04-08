#!/usr/bin/env bash
# Usage: get_review_range.sh [N]
# Prints BASE_SHA and HEAD_SHA for the fix commit range (default N=1).
# Fails if the working tree has uncommitted changes.
set -euo pipefail

N="${1:-1}"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Uncommitted changes detected. Commit the fix first." >&2
  exit 1
fi

echo "BASE_SHA=$(git rev-parse "HEAD~${N}")"
echo "HEAD_SHA=$(git rev-parse HEAD)"
