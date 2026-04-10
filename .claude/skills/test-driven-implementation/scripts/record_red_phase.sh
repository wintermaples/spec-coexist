#!/usr/bin/env bash
# record_red_phase.sh — run a test, assert it FAILS, write tdd-red evidence.
#
# Usage: record_red_phase.sh <slug> -- <test-cmd> [args...]
#
# Exit codes:
#   0  test failed as expected; evidence written
#   2  bad usage
#   3  test unexpectedly passed (RED violation)

set -euo pipefail

if [[ $# -lt 3 || "$2" != "--" ]]; then
    echo "usage: $0 <slug> -- <test-cmd> [args...]" >&2
    exit 2
fi

SLUG="$1"; shift 2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="${SCRIPT_DIR}/../../_shared/scripts/write_evidence.sh"

LOG="$(mktemp)"
set +e
"$@" >"${LOG}" 2>&1
RC=$?
set -e

if [[ ${RC} -eq 0 ]]; then
    echo "FAIL: RED phase test unexpectedly passed for slug '${SLUG}'" >&2
    cat "${LOG}" >&2
    rm -f "${LOG}"
    exit 3
fi

PROOF="tdd-red slug=${SLUG} cmd='$*' rc=${RC}
$(tail -n 20 "${LOG}")"
OUTPUT_TAIL="$(tail -n 20 "${LOG}")"
rm -f "${LOG}"

# Write markdown evidence (legacy)
bash "${SHARED}" code "tdd-red:${SLUG}" "${PROOF}" pass

# Write JSON evidence (WP2)
JSON_SCRIPT="${SCRIPT_DIR}/../../_shared/scripts/write_evidence_json.sh"
if [[ -x "${JSON_SCRIPT}" ]]; then
    bash "${JSON_SCRIPT}" tdd-red code "tdd-red:${SLUG}" pass "$*" "${RC}" "${OUTPUT_TAIL}"
fi
