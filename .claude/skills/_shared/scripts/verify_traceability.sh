#!/usr/bin/env bash
# verify_traceability.sh — verify REQ-ID <-> test-ID bidirectional traceability.
#
# Usage:
#   verify_traceability.sh [<base-ref>]
#
# Scans:
#   - docs/ for REQ-<subsystem>-<n> identifiers
#   - test files for [REQ-xxx] tags
#   - .spec-coexist/evidence/ for verification records
#
# Reports:
#   - Uncovered REQ-IDs (no test references)
#   - Orphan tests (reference non-existent REQ-IDs)
#   - REQ-IDs without verification evidence
#
# Exit codes:
#   0  all REQ-IDs covered
#   1  uncovered REQ-IDs or orphan tests found
#   2  bad usage

set -euo pipefail

BASE_REF="${1:-main}"

# Locate repo root
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

DOCS_DIR="${REPO_ROOT}/docs"
EVIDENCE_DIR="${REPO_ROOT}/.spec-coexist/evidence"

ERRORS=0
WARNINGS=0

fail() {
    echo "FAIL: $*" >&2
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "WARN: $*" >&2
    WARNINGS=$((WARNINGS + 1))
}

info() {
    echo "INFO: $*"
}

# ─── Step 1: Collect all REQ-IDs from docs ───
REQ_IDS_FILE="$(mktemp)"
if [[ -d "${DOCS_DIR}" ]]; then
    grep -rhoP 'REQ-[A-Z0-9_]+-[0-9]+' "${DOCS_DIR}" 2>/dev/null | sort -u > "${REQ_IDS_FILE}" || true
fi

REQ_COUNT=$(wc -l < "${REQ_IDS_FILE}" | tr -d ' ')
info "Found ${REQ_COUNT} unique REQ-ID(s) in docs/"

if [[ ${REQ_COUNT} -eq 0 ]]; then
    info "No REQ-IDs found — traceability check not applicable"
    rm -f "${REQ_IDS_FILE}"
    exit 0
fi

# ─── Step 2: Collect all REQ-ID references from test files ───
TEST_REFS_FILE="$(mktemp)"
# Search common test patterns
for pattern in '*test*' '*spec*' '*__tests__*' 'tests/*' '*_test.*'; do
    find "${REPO_ROOT}" -path '*/.git' -prune -o \
        -path '*/node_modules' -prune -o \
        -path '*/.spec-coexist' -prune -o \
        -path '*/docs' -prune -o \
        -name "${pattern}" -type f -print 2>/dev/null \
        | xargs grep -hoP 'REQ-[A-Z0-9_]+-[0-9]+' 2>/dev/null >> "${TEST_REFS_FILE}" || true
done
sort -u -o "${TEST_REFS_FILE}" "${TEST_REFS_FILE}"

TEST_REF_COUNT=$(wc -l < "${TEST_REFS_FILE}" | tr -d ' ')
info "Found ${TEST_REF_COUNT} unique REQ-ID reference(s) in test files"

# ─── Step 3: Collect REQ-IDs from evidence ───
EVIDENCE_REFS_FILE="$(mktemp)"
if [[ -d "${EVIDENCE_DIR}" ]]; then
    find "${EVIDENCE_DIR}" -name '*.json' -print0 2>/dev/null \
        | xargs -0 grep -hoP 'REQ-[A-Z0-9_]+-[0-9]+' 2>/dev/null \
        | sort -u > "${EVIDENCE_REFS_FILE}" || true
fi

# ─── Step 4: Check coverage ───

# Uncovered REQ-IDs (in docs but not in tests)
UNCOVERED_FILE="$(mktemp)"
comm -23 "${REQ_IDS_FILE}" "${TEST_REFS_FILE}" > "${UNCOVERED_FILE}"
UNCOVERED_COUNT=$(wc -l < "${UNCOVERED_FILE}" | tr -d ' ')

if [[ ${UNCOVERED_COUNT} -gt 0 ]]; then
    fail "${UNCOVERED_COUNT} REQ-ID(s) have no test coverage:"
    while IFS= read -r req_id; do
        echo "  - ${req_id}" >&2
    done < "${UNCOVERED_FILE}"
fi

# Orphan test references (in tests but not in docs)
ORPHAN_FILE="$(mktemp)"
comm -23 "${TEST_REFS_FILE}" "${REQ_IDS_FILE}" > "${ORPHAN_FILE}"
ORPHAN_COUNT=$(wc -l < "${ORPHAN_FILE}" | tr -d ' ')

if [[ ${ORPHAN_COUNT} -gt 0 ]]; then
    warn "${ORPHAN_COUNT} test(s) reference non-existent REQ-ID(s):"
    while IFS= read -r req_id; do
        echo "  - ${req_id}" >&2
    done < "${ORPHAN_FILE}"
fi

# REQ-IDs without verification evidence
if [[ -d "${EVIDENCE_DIR}" ]]; then
    UNVERIFIED_FILE="$(mktemp)"
    comm -23 "${REQ_IDS_FILE}" "${EVIDENCE_REFS_FILE}" > "${UNVERIFIED_FILE}"
    UNVERIFIED_COUNT=$(wc -l < "${UNVERIFIED_FILE}" | tr -d ' ')

    if [[ ${UNVERIFIED_COUNT} -gt 0 ]]; then
        warn "${UNVERIFIED_COUNT} REQ-ID(s) have no verification evidence:"
        while IFS= read -r req_id; do
            echo "  - ${req_id}" >&2
        done < "${UNVERIFIED_FILE}"
    fi
    rm -f "${UNVERIFIED_FILE}"
fi

# ─── Cleanup ───
rm -f "${REQ_IDS_FILE}" "${TEST_REFS_FILE}" "${EVIDENCE_REFS_FILE}" "${UNCOVERED_FILE}" "${ORPHAN_FILE}"

# ─── Report ───
if [[ ${ERRORS} -gt 0 ]]; then
    echo "verify_traceability.sh: FAILED — ${ERRORS} error(s), ${WARNINGS} warning(s)" >&2
    exit 1
fi

if [[ ${WARNINGS} -gt 0 ]]; then
    echo "verify_traceability.sh: PASSED with ${WARNINGS} warning(s)"
else
    echo "verify_traceability.sh: PASSED — all REQ-IDs covered"
fi
