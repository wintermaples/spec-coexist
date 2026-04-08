#!/usr/bin/env bash
# record_green_phase.sh — run a test, assert it PASSES, write tdd-green evidence.
#
# Usage: record_green_phase.sh <slug> -- <test-cmd> [args...]
#
# Exit codes:
#   0  test passed; evidence written
#   2  bad usage
#   3  test failed (GREEN violation — fix code, do not record success)

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

if [[ ${RC} -ne 0 ]]; then
    echo "FAIL: GREEN phase test still failing for slug '${SLUG}'" >&2
    cat "${LOG}" >&2
    rm -f "${LOG}"
    exit 3
fi

PROOF="tdd-green slug=${SLUG} cmd='$*' rc=0
$(tail -n 20 "${LOG}")"
rm -f "${LOG}"

bash "${SHARED}" code "tdd-green:${SLUG}" "${PROOF}" pass
