#!/usr/bin/env bash
# run_gate_checklist.sh — pre-flight checker for verification-before-completion
# Usage: run_gate_checklist.sh [code|document]
# Exits 0 if all checks pass, 1 otherwise. Does NOT run tests — only verifies tooling.
set -euo pipefail

MODE="${1:-}"
FAILED=0
pass() { printf "  [PASS] %s\n" "$*"; }
fail() { printf "  [FAIL] %s\n" "$*"; FAILED=$((FAILED + 1)); }
info() { printf "  [INFO] %s\n" "$*"; }

echo "=== verification-before-completion: pre-flight (mode: ${MODE:-any}) ==="
echo ""
echo "-- Universal --"
if git rev-parse --git-dir >/dev/null 2>&1; then pass "inside git repo"; else info "not a git repo"; fi

if [[ "$MODE" == "code" || -z "$MODE" ]]; then
  echo ""
  echo "-- Code mode --"
  if   command -v pytest >/dev/null 2>&1; then pass "pytest: $(command -v pytest)"
  elif [ -f package.json ] && command -v npx >/dev/null 2>&1; then pass "npx (Node) present"
  elif command -v go >/dev/null 2>&1 && [ -f go.mod ]; then pass "go: $(command -v go)"
  else fail "no recognised test runner found (pytest / npx / go)"
  fi
  if   command -v mypy >/dev/null 2>&1; then pass "mypy present"
  elif command -v tsc  >/dev/null 2>&1; then pass "tsc present"
  else info "no type checker found — document if project has none"
  fi
  if   command -v ruff    >/dev/null 2>&1; then pass "ruff present"
  elif command -v flake8  >/dev/null 2>&1; then pass "flake8 present"
  elif command -v eslint  >/dev/null 2>&1; then pass "eslint present"
  else info "no linter found — document if project has none"
  fi
fi

if [[ "$MODE" == "document" || -z "$MODE" ]]; then
  echo ""
  echo "-- Document mode --"
  CHECK_DOC="$(dirname "$0")/../../_shared/scripts/check_doc_exists.sh"
  if [ -f "$CHECK_DOC" ]; then pass "check_doc_exists.sh present"
  else fail "check_doc_exists.sh not found at $CHECK_DOC"
  fi
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "=== PRE-FLIGHT PASSED — proceed to gate steps 1-5 ==="
  exit 0
else
  echo "=== PRE-FLIGHT FAILED ($FAILED check(s)) ==="
  exit 1
fi
