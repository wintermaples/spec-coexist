#!/usr/bin/env bash
# run_all_tests.sh — unified test runner for the spec-coexist skill suite.
#
# Runs all test suites in sequence:
#   1. Trigger routing tests  (run_trigger_tests.sh)
#   2. Evidence validation tests (run_evidence_tests.sh)
#   3. Packaging tests (run_packaging_tests.sh)
#
# Exit codes:
#   0  all suites pass
#   1  one or more suites failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILURES=()

run_suite() {
    local name="$1"
    local script="$2"
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║  ${name}"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    if bash "$script"; then
        echo ""
        echo "✓ ${name}: PASSED"
    else
        echo ""
        echo "✗ ${name}: FAILED"
        FAILURES+=("$name")
    fi
}

run_suite "1. Trigger Routing Tests" "${SCRIPT_DIR}/run_trigger_tests.sh"
run_suite "2. Evidence Validation Tests" "${SCRIPT_DIR}/run_evidence_tests.sh"
run_suite "3. Packaging Tests" "${SCRIPT_DIR}/run_packaging_tests.sh"

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║  SUMMARY                              ║"
echo "╚═══════════════════════════════════════╝"

if [[ ${#FAILURES[@]} -gt 0 ]]; then
    echo ""
    echo "FAILED suites:"
    for f in "${FAILURES[@]}"; do
        echo "  - ${f}"
    done
    echo ""
    echo "Result: ${#FAILURES[@]} suite(s) FAILED"
    exit 1
fi

echo ""
echo "Result: All 3 suites PASSED"
exit 0
