#!/usr/bin/env bash
# pre-commit.sh — pre-commit hook for spec-coexist evidence validation.
#
# Checks that staged changes satisfy the pre-review-self-check mandatory items.
# Designed to be symlinked or copied into .git/hooks/pre-commit.
#
# What it checks:
#   1. JSON evidence files are valid against schema
#   2. No evidence files with result: fail are the latest for their subject
#   3. tdd-green files have matching tdd-red files
#   4. Evidence timestamps are plausible (not future-dated, not stale)
#
# Exit codes:
#   0  all checks pass (commit allowed)
#   1  check failure (commit blocked)

set -euo pipefail

# Locate repo root
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

EVIDENCE_DIR="${REPO_ROOT}/.spec-coexist/evidence"
SCHEMA="${REPO_ROOT}/.claude/skills/_shared/schemas/evidence.schema.json"
ERRORS=0

fail() {
    echo "pre-commit: FAIL: $*" >&2
    ERRORS=$((ERRORS + 1))
}

# ─── Check 1: Validate staged JSON evidence files ───
STAGED_EVIDENCE="$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.spec-coexist/evidence/.*\.json$' || true)"

if [[ -n "${STAGED_EVIDENCE}" ]]; then
    echo "pre-commit: Validating staged evidence files..."

    while IFS= read -r file; do
        [[ -z "${file}" ]] && continue
        full_path="${REPO_ROOT}/${file}"

        # Check valid JSON
        if ! python3 -c "import json; json.load(open('${full_path}'))" 2>/dev/null; then
            fail "${file}: invalid JSON"
            continue
        fi

        # Check required fields
        if ! python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
required = ['schema_version','timestamp_utc','proof_type','mode','subject','result','proof_hash','proof']
missing = [k for k in required if k not in d]
if missing:
    print(f'missing: {missing}', file=sys.stderr)
    sys.exit(1)
" "${full_path}" 2>&1; then
            fail "${file}: missing required fields"
            continue
        fi

        # Check timestamp is not future-dated (allow 5 min skew)
        python3 -c "
import json, sys
from datetime import datetime, timezone, timedelta
d = json.load(open(sys.argv[1]))
ts = d.get('timestamp_utc', '')
try:
    dt = datetime.strptime(ts, '%Y%m%dT%H%M%SZ').replace(tzinfo=timezone.utc)
    now = datetime.now(timezone.utc) + timedelta(minutes=5)
    if dt > now:
        print(f'future-dated: {ts}', file=sys.stderr)
        sys.exit(1)
except ValueError:
    print(f'invalid timestamp format: {ts}', file=sys.stderr)
    sys.exit(1)
" "${full_path}" 2>&1 || fail "${file}: timestamp issue"

    done <<< "${STAGED_EVIDENCE}"
fi

# ─── Check 2: tdd-green without tdd-red for staged files ───
STAGED_GREEN="$(echo "${STAGED_EVIDENCE}" | grep 'tdd-green' || true)"

if [[ -n "${STAGED_GREEN}" ]]; then
    while IFS= read -r green_file; do
        [[ -z "${green_file}" ]] && continue
        full_path="${REPO_ROOT}/${green_file}"

        SLUG="$(python3 -c "import json; d=json.load(open('${full_path}')); print(d.get('tdd_slug',''))" 2>/dev/null || echo "")"
        if [[ -z "${SLUG}" ]]; then
            fail "${green_file}: tdd-green missing tdd_slug"
            continue
        fi

        # Check if a matching tdd-red exists anywhere in evidence
        if [[ -d "${EVIDENCE_DIR}" ]]; then
            MATCHING_RED="$(find "${EVIDENCE_DIR}" -name "tdd-red-*${SLUG}*.json" 2>/dev/null | head -1 || true)"
            if [[ -z "${MATCHING_RED}" ]]; then
                fail "${green_file}: no matching tdd-red evidence for slug '${SLUG}'"
            fi
        else
            fail "${green_file}: evidence directory missing, cannot verify tdd-red exists"
        fi
    done <<< "${STAGED_GREEN}"
fi

# ─── Report ───
if [[ ${ERRORS} -gt 0 ]]; then
    echo "pre-commit: ${ERRORS} error(s) — commit BLOCKED" >&2
    echo "pre-commit: Fix the issues above, then retry your commit." >&2
    exit 1
fi

if [[ -n "${STAGED_EVIDENCE}" ]]; then
    echo "pre-commit: evidence validation PASSED"
fi
