#!/usr/bin/env bash
# record_test_failure.sh — run a failing test command and persist the RED evidence.
#
# Usage:
#   record_test_failure.sh <subject-slug> -- <test-command> [args...]
#
# Arguments:
#   subject-slug   short identifier for the subject under test (e.g. "payment-refund")
#   --             literal separator
#   test-command   the exact command that SHOULD fail right now (the RED of Red-Green-Refactor)
#
# Behaviour:
#   - Executes the command, captures stdout+stderr and exit code.
#   - REQUIRES non-zero exit code. If the command passes (exit 0), the script
#     fails with exit 3 and writes nothing — a passing test is NOT a RED record.
#   - On a real failure, writes docs/evidence/red-<UTC-timestamp>-<slug>.log and
#     prints the relative path on stdout so the caller can cite it.
#
# This script is the evidence source for the TDD gate embedded in
# implementing-from-spec and revising-implementation. See
# implementing-from-spec/references/tdd-discipline.md.

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "usage: $0 <subject-slug> -- <test-command> [args...]" >&2
    exit 2
fi

SUBJECT="$1"
shift
if [[ "${1:-}" != "--" ]]; then
    echo "FAIL: expected '--' separator after subject-slug" >&2
    exit 2
fi
shift

if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

EVIDENCE_DIR="${REPO_ROOT}/docs/evidence"
mkdir -p "${EVIDENCE_DIR}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
SLUG="$(printf '%s' "${SUBJECT}" | tr '[:upper:] /:' '[:lower:]---' | tr -cd 'a-z0-9-' | cut -c1-40)"
[[ -z "${SLUG}" ]] && SLUG="unnamed"
OUT="${EVIDENCE_DIR}/red-${TIMESTAMP}-${SLUG}.log"

set +e
OUTPUT="$("$@" 2>&1)"
CODE=$?
set -e

if [[ ${CODE} -eq 0 ]]; then
    echo "FAIL: test command exited 0 — no RED observed, refusing to record" >&2
    echo "--- command output ---" >&2
    printf '%s\n' "${OUTPUT}" >&2
    exit 3
fi

{
    echo "# RED evidence — ${SUBJECT}"
    echo
    echo "- timestamp_utc: ${TIMESTAMP}"
    echo "- exit_code: ${CODE}"
    echo "- command: $*"
    echo
    echo '```'
    printf '%s\n' "${OUTPUT}"
    echo '```'
} > "${OUT}"

printf '%s\n' "${OUT#${REPO_ROOT}/}"
