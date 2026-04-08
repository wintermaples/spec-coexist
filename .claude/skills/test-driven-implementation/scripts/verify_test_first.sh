#!/usr/bin/env bash
# verify_test_first.sh — heuristic check that tests appeared before production code.
#
# Walks `git log <base>..HEAD` for the current branch and warns when a commit
# touches non-test files without any preceding commit (in the same range) that
# touched a test file. False positives are tolerated; this is an alert, not a
# blocker — the spec-coexist Iron Law remains the source of truth.
#
# Usage: verify_test_first.sh [<base-ref>]
#   default base-ref: main

set -euo pipefail

BASE="${1:-main}"

if ! git rev-parse --verify "${BASE}" >/dev/null 2>&1; then
    echo "verify_test_first.sh: base ref '${BASE}' not found, skipping" >&2
    exit 0
fi

RANGE="${BASE}..HEAD"
SAW_TEST=0
VIOLATIONS=0

for SHA in $(git rev-list --reverse "${RANGE}"); do
    FILES="$(git show --name-only --pretty=format: "${SHA}" | sed '/^$/d')"
    HAS_TEST=0
    HAS_PROD=0
    while IFS= read -r f; do
        case "${f}" in
            *test*|*spec*|*__tests__*|tests/*|*_test.go|*_test.py)
                HAS_TEST=1 ;;
            *.md|*.json|*.yaml|*.yml|*.toml|.gitignore|Dockerfile*)
                : ;;
            *) HAS_PROD=1 ;;
        esac
    done <<< "${FILES}"

    if [[ ${HAS_TEST} -eq 1 ]]; then SAW_TEST=1; fi
    if [[ ${HAS_PROD} -eq 1 && ${SAW_TEST} -eq 0 ]]; then
        echo "WARN: ${SHA} adds production code with no preceding test commit in ${RANGE}"
        VIOLATIONS=$((VIOLATIONS+1))
    fi
done

if [[ ${VIOLATIONS} -gt 0 ]]; then
    echo "verify_test_first.sh: ${VIOLATIONS} potential Iron Law violation(s)" >&2
    exit 1
fi
echo "verify_test_first.sh: OK"
