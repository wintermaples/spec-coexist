#!/usr/bin/env bash
# write_evidence_json.sh — write a JSON evidence record under .spec-coexist/evidence/
#
# Usage:
#   write_evidence_json.sh <proof-type> <mode> <subject> <result> <proof-command> <exit-code> [<output-tail>]
#
# Optional env vars:
#   EVIDENCE_TASK_ID   — task identifier for grouping
#   EVIDENCE_REVIEW_REF — review outcome reference
#   EVIDENCE_TDD_SLUG  — for tdd-green: must match prior tdd-red slug
#   EVIDENCE_NOTES     — free-form notes
#
# Writes: .spec-coexist/evidence/<task-id>/<proof-type>-<timestamp>-<slug>.json
# Prints: the path of the evidence file (relative to repo root)

set -euo pipefail

if [[ $# -lt 6 ]]; then
    echo "usage: $0 <proof-type> <mode> <subject> <result> <proof-command> <exit-code> [output-tail]" >&2
    exit 2
fi

PROOF_TYPE="$1"
MODE="$2"
SUBJECT="$3"
RESULT="$4"
PROOF_CMD="$5"
EXIT_CODE="$6"
OUTPUT_TAIL="${7:-}"

# Validate proof_type
case "${PROOF_TYPE}" in
    tdd-red|tdd-green|verification-result|self-check-result|debug-hypothesis|tdd-waiver) ;;
    *) echo "FAIL: unknown proof-type '${PROOF_TYPE}'" >&2; exit 2 ;;
esac

# Validate mode
case "${MODE}" in
    code|document) ;;
    *) echo "FAIL: mode must be 'code' or 'document', got '${MODE}'" >&2; exit 2 ;;
esac

# Validate result
case "${RESULT}" in
    pass|fail) ;;
    *) echo "FAIL: result must be 'pass' or 'fail', got '${RESULT}'" >&2; exit 2 ;;
esac

# Locate repo root
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

# Task ID defaults to "default"
TASK_ID="${EVIDENCE_TASK_ID:-default}"

EVIDENCE_DIR="${REPO_ROOT}/.spec-coexist/evidence/${TASK_ID}"
mkdir -p "${EVIDENCE_DIR}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
SLUG="$(printf '%s' "${SUBJECT}" | tr '[:upper:] /:' '[:lower:]---' | tr -cd 'a-z0-9-' | cut -c1-40)"
if [[ -z "${SLUG}" ]]; then
    SLUG="unnamed"
fi

OUT="${EVIDENCE_DIR}/${PROOF_TYPE}-${TIMESTAMP}-${SLUG}.json"

# Compute proof hash
if command -v sha256sum >/dev/null 2>&1; then
    HASH="$(printf '%s\n%s\n' "${SUBJECT}" "${PROOF_CMD}" | sha256sum | cut -c1-12)"
else
    HASH="$(printf '%s\n%s\n' "${SUBJECT}" "${PROOF_CMD}" | shasum -a 256 | cut -c1-12)"
fi

# Get current commit SHA
COMMIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"

# Escape strings for JSON (handle newlines, quotes, backslashes)
json_escape() {
    printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()), end="")' 2>/dev/null \
        || printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')"
}

# Build JSON
{
    cat <<JSONHEAD
{
  "schema_version": "1.0.0",
  "timestamp_utc": "${TIMESTAMP}",
  "proof_type": "${PROOF_TYPE}",
  "mode": "${MODE}",
  "subject": $(json_escape "${SUBJECT}"),
  "result": "${RESULT}",
  "proof_hash": "${HASH}",
  "slug": "${SLUG}",
  "commit_sha": "${COMMIT_SHA}",
  "task_id": $(json_escape "${TASK_ID}"),
  "proof": {
    "command": $(json_escape "${PROOF_CMD}"),
    "exit_code": ${EXIT_CODE}$(if [[ -n "${OUTPUT_TAIL}" ]]; then printf ',\n    "output_tail": %s' "$(json_escape "${OUTPUT_TAIL}")"; fi)
  }
JSONHEAD

    # Optional fields
    if [[ -n "${EVIDENCE_REVIEW_REF:-}" ]]; then
        printf '  ,"review_ref": %s\n' "$(json_escape "${EVIDENCE_REVIEW_REF}")"
    fi
    if [[ -n "${EVIDENCE_TDD_SLUG:-}" ]]; then
        printf '  ,"tdd_slug": %s\n' "$(json_escape "${EVIDENCE_TDD_SLUG}")"
    fi
    if [[ -n "${EVIDENCE_NOTES:-}" ]]; then
        printf '  ,"notes": %s\n' "$(json_escape "${EVIDENCE_NOTES}")"
    fi

    echo "}"
} > "${OUT}"

# Print the relative path
printf '%s\n' "${OUT#${REPO_ROOT}/}"
