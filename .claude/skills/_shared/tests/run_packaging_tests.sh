#!/usr/bin/env bash
# run_packaging_tests.sh — test package-spec-coexist.sh output for completeness and correctness.
#
# Tests:
#   P1: Packaging produces a tarball
#   P2: All skill SKILL.md files are present in tarball
#   P3: plugin.json has required fields and valid semver
#   P4: No junk files (.DS_Store, __pycache__, .pyc) in tarball
#   P5: Idempotent — two consecutive builds produce identical content
#   P6: _shared resources (schemas, scripts) are included
#
# Exit codes:
#   0  all tests pass
#   1  one or more tests failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
fi
PACKAGE_SCRIPT="${REPO_ROOT}/scripts/package-spec-coexist.sh"
SKILLS_DIR="${REPO_ROOT}/.claude/skills"

PASS=0
FAIL=0
ERRORS=()

pass() {
    PASS=$((PASS + 1))
    echo "  PASS: $1"
}

fail() {
    FAIL=$((FAIL + 1))
    ERRORS+=("$1")
    echo "  FAIL: $1"
}

echo "=== Packaging Tests ==="

# ─── P1: Build produces a tarball ───
echo ""
echo "--- P1: Build produces tarball ---"

# Clean dist first
rm -f "${REPO_ROOT}"/dist/spec-coexist-*.tar.gz 2>/dev/null || true

BUILD_OUTPUT="$(bash "$PACKAGE_SCRIPT" 2>&1)" || {
    fail "P1: package script exited non-zero"
    echo "Output: $BUILD_OUTPUT"
    # Cannot continue if build fails
    echo ""
    echo "========================================"
    echo "Packaging tests: ${PASS}/$((PASS + FAIL)) passed, ${FAIL} failed"
    exit 1
}

ARCHIVE="$(echo "$BUILD_OUTPUT" | grep '^built ' | sed 's/^built //')"
if [[ -f "$ARCHIVE" ]]; then
    pass "P1: tarball created at ${ARCHIVE}"
else
    fail "P1: tarball not found (expected from build output)"
    echo "Build output: $BUILD_OUTPUT"
    exit 1
fi

# Get tarball contents once for all subsequent tests
CONTENTS="$(tar -tzf "$ARCHIVE")"

# ─── P2: All skill SKILL.md files present ───
echo ""
echo "--- P2: Skill completeness ---"

p2_errors=0
for skill_dir in "${SKILLS_DIR}"/*/; do
    skill_name="$(basename "$skill_dir")"
    # Skip infrastructure prefixed dirs
    case "$skill_name" in
        _*) continue ;;
    esac
    skill_md="${skill_dir}SKILL.md"
    if [[ -f "$skill_md" ]]; then
        expected_path="spec-coexist/skills/${skill_name}/SKILL.md"
        if echo "$CONTENTS" | grep -qF "$expected_path"; then
            pass "P2: ${skill_name}/SKILL.md present"
        else
            fail "P2: ${skill_name}/SKILL.md MISSING from tarball"
            p2_errors=$((p2_errors + 1))
        fi
    fi
done

# ─── P3: plugin.json validity ───
echo ""
echo "--- P3: plugin.json validity ---"

# Extract plugin.json from tarball
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tar -xzf "$ARCHIVE" -C "$tmpdir"
PLUGIN_JSON="${tmpdir}/spec-coexist/.claude-plugin/plugin.json"

if [[ -f "$PLUGIN_JSON" ]]; then
    pass "P3a: plugin.json exists in tarball"
else
    fail "P3a: plugin.json missing from tarball"
fi

# Validate JSON syntax
if python3 -c "import json; json.load(open('${PLUGIN_JSON}'))" 2>/dev/null; then
    pass "P3b: plugin.json is valid JSON"
else
    fail "P3b: plugin.json is not valid JSON"
fi

# Check required fields
REQUIRED_CHECK="$(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
required = ['name', 'description', 'version']
missing = [k for k in required if k not in d]
if missing:
    print('missing: ' + ', '.join(missing))
    sys.exit(1)
print('ok')
" "$PLUGIN_JSON" 2>&1)" || true

if [[ "$REQUIRED_CHECK" == "ok" ]]; then
    pass "P3c: required fields (name, description, version) present"
else
    fail "P3c: ${REQUIRED_CHECK}"
fi

# Validate semver format
SEMVER_CHECK="$(python3 -c "
import json, sys, re
d = json.load(open(sys.argv[1]))
v = d.get('version', '')
if re.match(r'^[0-9]+\.[0-9]+\.[0-9]+$', v):
    print('ok')
else:
    print(f'invalid semver: {v}')
    sys.exit(1)
" "$PLUGIN_JSON" 2>&1)" || true

if [[ "$SEMVER_CHECK" == "ok" ]]; then
    pass "P3d: version is valid semver"
else
    fail "P3d: ${SEMVER_CHECK}"
fi

# ─── P4: No junk files ───
echo ""
echo "--- P4: Junk file exclusion ---"

JUNK_PATTERNS=(".DS_Store" "__pycache__" ".pyc" ".pyo" "Thumbs.db" ".swp")
junk_found=0
for pattern in "${JUNK_PATTERNS[@]}"; do
    if echo "$CONTENTS" | grep -q "$pattern"; then
        fail "P4: junk file found in tarball matching '${pattern}'"
        junk_found=1
    fi
done
if [[ $junk_found -eq 0 ]]; then
    pass "P4: no junk files in tarball"
fi

# ─── P5: Idempotent packaging ───
echo ""
echo "--- P5: Idempotent packaging ---"

# Build again
BUILD_OUTPUT2="$(bash "$PACKAGE_SCRIPT" 2>&1)"
ARCHIVE2="$(echo "$BUILD_OUTPUT2" | grep '^built ' | sed 's/^built //')"

if [[ -f "$ARCHIVE2" ]]; then
    # Compare contents (not checksums — timestamps may differ)
    CONTENTS2="$(tar -tzf "$ARCHIVE2")"
    if [[ "$CONTENTS" == "$CONTENTS2" ]]; then
        pass "P5: idempotent — two builds produce same file listing"
    else
        fail "P5: non-idempotent — file listings differ between builds"
        diff <(echo "$CONTENTS") <(echo "$CONTENTS2") || true
    fi
else
    fail "P5: second build did not produce tarball"
fi

# ─── P6: _shared resources included ───
echo ""
echo "--- P6: Shared resources ---"

# Schema
if echo "$CONTENTS" | grep -q "spec-coexist/skills/_shared/schemas/evidence.schema.json"; then
    pass "P6a: evidence.schema.json included"
else
    fail "P6a: evidence.schema.json MISSING"
fi

# Key scripts
for script in validate_evidence.sh verify_evidence.sh pre-commit.sh write_evidence.sh; do
    if echo "$CONTENTS" | grep -q "spec-coexist/skills/_shared/scripts/${script}"; then
        pass "P6b: _shared/scripts/${script} included"
    else
        fail "P6b: _shared/scripts/${script} MISSING"
    fi
done

# Tests
if echo "$CONTENTS" | grep -q "spec-coexist/skills/_shared/tests/run_trigger_tests.sh"; then
    pass "P6c: test runner included"
else
    fail "P6c: test runner MISSING"
fi

# =======================================
# Summary
# ═══════════════════════════════════════
echo ""
echo "═══════════════════════════════════════"
TOTAL=$((PASS + FAIL))
echo "Packaging tests: ${PASS}/${TOTAL} passed, ${FAIL} failed"

if [[ ${FAIL} -gt 0 ]]; then
    echo ""
    echo "Failed tests:"
    for err in "${ERRORS[@]}"; do
        echo "  - ${err}"
    done
    exit 1
fi

echo "All packaging tests PASSED"
exit 0
