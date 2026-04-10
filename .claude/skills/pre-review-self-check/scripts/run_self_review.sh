#!/usr/bin/env bash
# run_self_review.sh — prepare a self-review context for pre-review-self-check.
#
# Emits:
#   - BASE_SHA / HEAD_SHA (shell-eval friendly)
#   - git diff --stat summary
#   - A findings skeleton (one "## <file>" block per changed file) the agent fills in
#
# Does NOT grade the code. The agent walks references/code-quality-checklist.md and fills the
# skeleton by hand. This script only frames the review.
#
# Usage: bash scripts/run_self_review.sh [--base <sha>]
# Exit:  0 on success, 1 if the working tree + index + HEAD^ diff is empty.

set -euo pipefail

BASE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --base) BASE="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [[ -z "${BASE}" ]]; then
    if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
        BASE="$(git rev-parse HEAD^)"
    else
        BASE="$(git rev-parse HEAD)"
    fi
fi
HEAD_SHA="$(git rev-parse HEAD)"

# Collect changed files: staged + unstaged + committed since BASE.
mapfile -t FILES < <(
    {
        git diff --name-only "${BASE}" HEAD
        git diff --name-only
        git diff --name-only --cached
    } | sort -u | sed '/^$/d'
)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "FAIL: no changes to self-review (base=${BASE} head=${HEAD_SHA})" >&2
    exit 1
fi

echo "BASE_SHA=${BASE}"
echo "HEAD_SHA=${HEAD_SHA}"
echo
echo "# Self-Review Context"
echo
echo "## Diff summary"
echo '```'
git diff --stat "${BASE}" -- "${FILES[@]}" 2>/dev/null || true
echo '```'
echo
echo "## Checklist (walk references/code-quality-checklist.md per file)"
echo
for f in "${FILES[@]}"; do
    echo "### ${f}"
    for section in SOLID Naming Complexity Boundaries "Error-handling" "Dead-code" Secrets Logging; do
        echo "- ${section}: <pass | fail: reason | n/a: reason>"
    done
    echo
done
echo "## Red-flag scan"
echo "- result: <clean | rejected: #<row>>"
