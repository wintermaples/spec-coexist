#!/usr/bin/env bash
# validate_evidence.sh — validate JSON evidence files against evidence.schema.json
#
# Usage:
#   validate_evidence.sh [<evidence-dir>]
#
# Defaults to .spec-coexist/evidence/ under the repo root.
# Validates all *.json files recursively.
#
# Exit codes:
#   0  all files valid
#   1  one or more validation errors
#   2  bad usage or missing dependencies

set -euo pipefail

# Check for python3 + jsonschema
if ! python3 -c "import jsonschema" 2>/dev/null; then
    echo "WARN: python3 jsonschema not available, falling back to structural check" >&2
    FALLBACK=1
else
    FALLBACK=0
fi

# Locate repo root
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

EVIDENCE_DIR="${1:-${REPO_ROOT}/.spec-coexist/evidence}"
SCHEMA="${REPO_ROOT}/.claude/skills/_shared/schemas/evidence.schema.json"

if [[ ! -d "${EVIDENCE_DIR}" ]]; then
    echo "validate_evidence.sh: no evidence directory at ${EVIDENCE_DIR}, nothing to validate"
    exit 0
fi

if [[ ! -f "${SCHEMA}" ]]; then
    echo "FAIL: schema not found at ${SCHEMA}" >&2
    exit 2
fi

TOTAL=0
ERRORS=0

while IFS= read -r -d '' file; do
    TOTAL=$((TOTAL + 1))

    if [[ ${FALLBACK} -eq 1 ]]; then
        # Structural check: valid JSON + required fields
        if ! python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
required = ['schema_version','timestamp_utc','proof_type','mode','subject','result','proof_hash','proof']
missing = [k for k in required if k not in d]
if missing:
    print(f'FAIL: {sys.argv[1]}: missing fields: {missing}', file=sys.stderr)
    sys.exit(1)
if d.get('proof_type') == 'tdd-green' and 'tdd_slug' not in d:
    print(f'FAIL: {sys.argv[1]}: tdd-green requires tdd_slug', file=sys.stderr)
    sys.exit(1)
if d.get('proof_type') == 'tdd-waiver' and 'waiver' not in d:
    print(f'FAIL: {sys.argv[1]}: tdd-waiver requires waiver', file=sys.stderr)
    sys.exit(1)
" "${file}" 2>&1; then
            ERRORS=$((ERRORS + 1))
        fi
    else
        # Full JSON Schema validation
        if ! python3 -c "
import json, sys
from jsonschema import validate, ValidationError

with open(sys.argv[1]) as f:
    instance = json.load(f)
with open(sys.argv[2]) as f:
    schema = json.load(f)

try:
    validate(instance=instance, schema=schema)
except ValidationError as e:
    print(f'FAIL: {sys.argv[1]}: {e.message}', file=sys.stderr)
    sys.exit(1)
" "${file}" "${SCHEMA}" 2>&1; then
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find "${EVIDENCE_DIR}" -name '*.json' -print0)

if [[ ${TOTAL} -eq 0 ]]; then
    echo "validate_evidence.sh: no JSON evidence files found in ${EVIDENCE_DIR}"
    exit 0
fi

if [[ ${ERRORS} -gt 0 ]]; then
    echo "validate_evidence.sh: ${ERRORS}/${TOTAL} file(s) FAILED validation" >&2
    exit 1
fi

echo "validate_evidence.sh: ${TOTAL} file(s) OK"
