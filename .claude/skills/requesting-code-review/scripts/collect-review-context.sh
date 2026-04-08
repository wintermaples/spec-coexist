#!/usr/bin/env bash
# collect-review-context.sh
# Usage: scripts/collect-review-context.sh [--base <sha>]
# Outputs BASE_SHA and HEAD_SHA for the review range.
set -euo pipefail

BASE_SHA=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE_SHA="${2:?--base requires a SHA}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Working tree has uncommitted changes." >&2
  echo "Either commit them first, or generate the diff manually:" >&2
  echo "  git diff HEAD          # unstaged" >&2
  echo "  git diff --cached HEAD # staged" >&2
  exit 1
fi

HEAD_SHA=$(git rev-parse HEAD)
[[ -z "$BASE_SHA" ]] && BASE_SHA=$(git rev-parse HEAD~1)

echo "BASE_SHA=${BASE_SHA}"
echo "HEAD_SHA=${HEAD_SHA}"
