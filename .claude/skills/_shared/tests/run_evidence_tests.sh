#!/usr/bin/env bash
# run_evidence_tests.sh — test validate_evidence.sh and verify_evidence.sh with fixtures.
#
# Tests:
#   Category A: validate_evidence.sh — schema validation (valid + invalid fixtures)
#   Category B: verify_evidence.sh  — tier-based completeness (scenario fixtures)
#
# Exit codes:
#   0  all tests pass
#   1  one or more tests failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures/evidence"
SCRIPTS_DIR="${SCRIPT_DIR}/../scripts"
VALIDATE="${SCRIPTS_DIR}/validate_evidence.sh"
VERIFY="${SCRIPTS_DIR}/verify_evidence.sh"

PASS=0
FAIL=0
SKIP=0
ERRORS=()

# Detect if jsonschema is available (full mode vs fallback structural check)
if python3 -c "import jsonschema" 2>/dev/null; then
    HAS_JSONSCHEMA=1
else
    HAS_JSONSCHEMA=0
    echo "NOTE: python3 jsonschema not installed — fallback mode active."
    echo "      Some invalid fixture tests will be skipped (pattern/enum/additionalProperties)."
    echo ""
fi

pass() {
    PASS=$((PASS + 1))
    echo "  PASS: $1"
}

skip() {
    SKIP=$((SKIP + 1))
    echo "  SKIP: $1 (requires jsonschema)"
}

fail() {
    FAIL=$((FAIL + 1))
    ERRORS+=("$1")
    echo "  FAIL: $1"
}

# ═══════════════════════════════════════════════════════════════
# Category A: validate_evidence.sh
# ═══════════════════════════════════════════════════════════════
echo "=== Category A: validate_evidence.sh ==="

# --- A1: Valid fixtures should all pass ---
echo ""
echo "--- A1: Valid fixtures (expect: exit 0) ---"
for f in "${FIXTURES_DIR}/valid/"*.json; do
    name="$(basename "$f")"
    # Create temp evidence dir with single file
    tmpdir="$(mktemp -d)"
    cp "$f" "$tmpdir/"
    if bash "$VALIDATE" "$tmpdir" >/dev/null 2>&1; then
        pass "valid/${name} → accepted"
    else
        fail "valid/${name} → rejected (should accept)"
    fi
    rm -rf "$tmpdir"
done

# --- A2: Invalid fixtures should all fail ---
echo ""
echo "--- A2: Invalid fixtures (expect: exit 1) ---"

# Fixtures that only fail with full jsonschema (pattern/enum/const/additionalProperties)
SCHEMA_ONLY_FIXTURES="bad-proof-hash.json bad-proof-type.json bad-schema-version.json bad-timestamp-format.json extra-field.json"

for f in "${FIXTURES_DIR}/invalid/"*.json; do
    name="$(basename "$f")"
    tmpdir="$(mktemp -d)"
    cp "$f" "$tmpdir/"

    # Check if this fixture requires jsonschema for detection
    is_schema_only=0
    for sf in $SCHEMA_ONLY_FIXTURES; do
        if [[ "$name" == "$sf" ]]; then is_schema_only=1; break; fi
    done

    if [[ $is_schema_only -eq 1 && $HAS_JSONSCHEMA -eq 0 ]]; then
        skip "invalid/${name} (pattern/enum/const check)"
        rm -rf "$tmpdir"
        continue
    fi

    if bash "$VALIDATE" "$tmpdir" >/dev/null 2>&1; then
        fail "invalid/${name} → accepted (should reject)"
    else
        pass "invalid/${name} → rejected"
    fi
    rm -rf "$tmpdir"
done

# Special case: non-JSON file renamed to .json
tmpdir="$(mktemp -d)"
cp "${FIXTURES_DIR}/invalid/not-json.txt" "$tmpdir/not-json.json"
if bash "$VALIDATE" "$tmpdir" >/dev/null 2>&1; then
    fail "invalid/not-json (as .json) → accepted (should reject)"
else
    pass "invalid/not-json (as .json) → rejected"
fi
rm -rf "$tmpdir"

# --- A3: Empty directory → exit 0 (no files to validate) ---
echo ""
echo "--- A3: Edge cases ---"
tmpdir="$(mktemp -d)"
if bash "$VALIDATE" "$tmpdir" >/dev/null 2>&1; then
    pass "empty dir → exit 0 (nothing to validate)"
else
    fail "empty dir → should exit 0"
fi
rm -rf "$tmpdir"

# Non-existent directory → exit 0
if bash "$VALIDATE" "/nonexistent/path" >/dev/null 2>&1; then
    pass "nonexistent dir → exit 0"
else
    fail "nonexistent dir → should exit 0"
fi

# ═══════════════════════════════════════════════════════════════
# Category B: verify_evidence.sh (tier-based scenarios)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "=== Category B: verify_evidence.sh ==="

# Helper: run verify_evidence.sh with a scenario fixture as a fake evidence dir.
# verify_evidence.sh locates evidence at $REPO_ROOT/.spec-coexist/evidence/$TASK_ID.
# We create a temp repo structure so it finds our fixtures.
run_verify_scenario() {
    local tier="$1"
    local scenario_dir="$2"
    local task_id="test-task"

    tmpdir="$(mktemp -d)"
    # Create fake repo structure
    mkdir -p "$tmpdir/.spec-coexist/evidence/${task_id}"
    cp "${scenario_dir}/"*.json "$tmpdir/.spec-coexist/evidence/${task_id}/"

    # Create minimal git repo so git rev-parse works
    (cd "$tmpdir" && git init -q && git commit --allow-empty -m "init" -q) 2>/dev/null

    # Copy schema so validate_evidence.sh can find it
    mkdir -p "$tmpdir/.claude/skills/_shared/schemas"
    cp "${SCRIPT_DIR}/../schemas/evidence.schema.json" "$tmpdir/.claude/skills/_shared/schemas/"

    # Copy validate_evidence.sh so verify_evidence.sh can call it
    mkdir -p "$tmpdir/.claude/skills/_shared/scripts"
    cp "$VALIDATE" "$tmpdir/.claude/skills/_shared/scripts/"

    # Run from inside the temp repo
    (cd "$tmpdir" && bash "$VERIFY" "$tier" "$task_id" HEAD) >/dev/null 2>&1
    local rc=$?
    rm -rf "$tmpdir"
    return $rc
}

# --- B1: T1 pass — red + green + verification-result ---
echo ""
echo "--- B1: T1 scenarios ---"
if run_verify_scenario "T1" "${FIXTURES_DIR}/scenarios/t1-pass"; then
    pass "t1-pass → PASSED"
else
    fail "t1-pass → should PASS"
fi

# --- B2: T1 no-red (green without red = backdating) ---
if run_verify_scenario "T1" "${FIXTURES_DIR}/scenarios/t1-no-red"; then
    fail "t1-no-red → should FAIL (backdating)"
else
    pass "t1-no-red → FAILED (backdating detected)"
fi

# --- B3: T1 no verification-result ---
if run_verify_scenario "T1" "${FIXTURES_DIR}/scenarios/t1-no-verification"; then
    fail "t1-no-verification → should FAIL"
else
    pass "t1-no-verification → FAILED (missing verification-result)"
fi

# --- B4: T1 waiver (tdd-waiver replaces red/green) ---
if run_verify_scenario "T1" "${FIXTURES_DIR}/scenarios/t1-waiver"; then
    pass "t1-waiver → PASSED (waiver accepted)"
else
    fail "t1-waiver → should PASS with waiver"
fi

# --- B5: T1 timestamp backdating (green timestamp < red timestamp) ---
if run_verify_scenario "T1" "${FIXTURES_DIR}/scenarios/t1-timestamp-backdating"; then
    fail "t1-timestamp-backdating → should FAIL"
else
    pass "t1-timestamp-backdating → FAILED (timestamp violation detected)"
fi

echo ""
echo "--- B2: T2 scenarios ---"
# --- B6: T2 pass — all required evidence ---
if run_verify_scenario "T2" "${FIXTURES_DIR}/scenarios/t2-pass"; then
    pass "t2-pass → PASSED"
else
    fail "t2-pass → should PASS"
fi

# --- B7: T2 missing self-check-result ---
if run_verify_scenario "T2" "${FIXTURES_DIR}/scenarios/t2-no-selfcheck"; then
    fail "t2-no-selfcheck → should FAIL"
else
    pass "t2-no-selfcheck → FAILED (missing self-check-result)"
fi

# --- B8: Bad usage (invalid tier) ---
echo ""
echo "--- B3: Usage errors ---"
if bash "$VERIFY" "TX" 2>/dev/null; then
    fail "invalid tier TX → should exit 2"
else
    rc=$?
    if [[ $rc -eq 2 ]]; then
        pass "invalid tier TX → exit 2"
    else
        fail "invalid tier TX → expected exit 2, got $rc"
    fi
fi

# No arguments
if bash "$VERIFY" 2>/dev/null; then
    fail "no args → should exit 2"
else
    rc=$?
    if [[ $rc -eq 2 ]]; then
        pass "no args → exit 2"
    else
        fail "no args → expected exit 2, got $rc"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
TOTAL=$((PASS + FAIL))
echo "Evidence tests: ${PASS}/${TOTAL} passed, ${FAIL} failed, ${SKIP} skipped"

if [[ ${FAIL} -gt 0 ]]; then
    echo ""
    echo "Failed tests:"
    for err in "${ERRORS[@]}"; do
        echo "  - ${err}"
    done
    exit 1
fi

echo "All evidence tests PASSED"
exit 0
