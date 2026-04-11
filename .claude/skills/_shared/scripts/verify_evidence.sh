#!/usr/bin/env bash
# verify_evidence.sh — verify evidence completeness for a task based on its tier.
#
# Usage:
#   verify_evidence.sh <tier> [<task-id>] [<base-ref>]
#
# Arguments:
#   tier      T0|T1|T2|T3
#   task-id   evidence task identifier (default: "default")
#   base-ref  git base ref for commit range (default: main)
#
# Tier-based gate policy:
#   T0: diff line count check only (lint sufficient)
#   T1: tdd-red -> tdd-green ordering + verification-result required
#   T2/T3: above + REQ->test traceability + self-check-result required
#
# Exit codes:
#   0  all checks pass
#   1  evidence incomplete or ordering violated
#   2  bad usage

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "usage: $0 <tier> [task-id] [base-ref]" >&2
    exit 2
fi

TIER="$1"
TASK_ID="${2:-default}"
BASE_REF="${3:-main}"

case "${TIER}" in
    T0|T1|T2|T3) ;;
    *) echo "FAIL: tier must be T0|T1|T2|T3, got '${TIER}'" >&2; exit 2 ;;
esac

# Locate repo root
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(pwd)"
fi

EVIDENCE_DIR="${REPO_ROOT}/.spec-coexist/evidence/${TASK_ID}"
ERRORS=0

fail() {
    echo "FAIL: $*" >&2
    ERRORS=$((ERRORS + 1))
}

info() {
    echo "INFO: $*"
}

# ─── T0: diff line count only ───
if [[ "${TIER}" == "T0" ]]; then
    if git rev-parse --verify "${BASE_REF}" >/dev/null 2>&1; then
        DIFF_LINES="$(git diff "${BASE_REF}"..HEAD --stat | tail -1 | grep -oP '\d+ insertion' | grep -oP '\d+' || echo 0)"
        DEL_LINES="$(git diff "${BASE_REF}"..HEAD --stat | tail -1 | grep -oP '\d+ deletion' | grep -oP '\d+' || echo 0)"
        TOTAL=$((DIFF_LINES + DEL_LINES))
        if [[ ${TOTAL} -gt 20 ]]; then
            fail "T0 task has ${TOTAL} changed lines (max 20). Consider upgrading to T1."
        else
            info "T0 diff size OK: ${TOTAL} lines"
        fi
    fi
    if [[ ${ERRORS} -gt 0 ]]; then exit 1; fi
    echo "verify_evidence.sh: T0 OK"
    exit 0
fi

# ─── T1+: evidence directory must exist ───
if [[ ! -d "${EVIDENCE_DIR}" ]]; then
    fail "No evidence directory at ${EVIDENCE_DIR}"
    echo "verify_evidence.sh: ${ERRORS} error(s)" >&2
    exit 1
fi

# ─── Helper: find evidence files by proof_type ───
find_by_type() {
    local proof_type="$1"
    find "${EVIDENCE_DIR}" -name '*.json' -print0 2>/dev/null \
        | xargs -0 grep -l "\"proof_type\": *\"${proof_type}\"" 2>/dev/null || true
}

# ─── T1+: tdd-red -> tdd-green ordering check ───
check_tdd_ordering() {
    local red_files green_files
    red_files="$(find_by_type "tdd-red")"
    green_files="$(find_by_type "tdd-green")"

    if [[ -z "${red_files}" && -z "${green_files}" ]]; then
        # Check for waivers
        local waiver_files
        waiver_files="$(find_by_type "tdd-waiver")"
        if [[ -z "${waiver_files}" ]]; then
            fail "No tdd-red, tdd-green, or tdd-waiver evidence found"
        else
            info "TDD waiver(s) found — skipping RED/GREEN check"
        fi
        return
    fi

    if [[ -z "${red_files}" && -n "${green_files}" ]]; then
        fail "tdd-green evidence exists without any tdd-red evidence (backdating suspected)"
        return
    fi

    # For each tdd-green, verify a matching tdd-red exists with an earlier timestamp
    while IFS= read -r green_file; do
        [[ -z "${green_file}" ]] && continue
        local green_ts green_slug
        green_ts="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['timestamp_utc'])" "${green_file}" 2>/dev/null || echo "")"
        green_slug="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('tdd_slug',''))" "${green_file}" 2>/dev/null || echo "")"

        if [[ -z "${green_slug}" ]]; then
            fail "${green_file}: tdd-green record missing tdd_slug field"
            continue
        fi

        # Find matching red
        local found_red=0
        while IFS= read -r red_file; do
            [[ -z "${red_file}" ]] && continue
            local red_subject red_ts_val
            red_subject="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['subject'])" "${red_file}" 2>/dev/null || echo "")"
            red_ts_val="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['timestamp_utc'])" "${red_file}" 2>/dev/null || echo "")"

            # Match slug in subject (tdd-red:<slug>)
            if [[ "${red_subject}" == *"${green_slug}"* ]]; then
                if [[ "${red_ts_val}" < "${green_ts}" || "${red_ts_val}" == "${green_ts}" ]]; then
                    found_red=1
                    break
                else
                    fail "${green_file}: tdd-green timestamp (${green_ts}) is BEFORE matching tdd-red (${red_ts_val}) — backdating"
                fi
            fi
        done <<< "${red_files}"

        if [[ ${found_red} -eq 0 ]]; then
            fail "${green_file}: no matching tdd-red found for slug '${green_slug}'"
        fi
    done <<< "${green_files}"

    info "TDD RED->GREEN ordering check complete"
}

# ─── T1+: verification-result required ───
check_verification_result() {
    local vr_files
    vr_files="$(find_by_type "verification-result")"
    if [[ -z "${vr_files}" ]]; then
        fail "No verification-result evidence found (required for ${TIER})"
    else
        # Check at least one is pass
        local has_pass=0
        while IFS= read -r vr_file; do
            [[ -z "${vr_file}" ]] && continue
            local result
            result="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['result'])" "${vr_file}" 2>/dev/null || echo "")"
            if [[ "${result}" == "pass" ]]; then
                has_pass=1
                break
            fi
        done <<< "${vr_files}"
        if [[ ${has_pass} -eq 0 ]]; then
            fail "No passing verification-result evidence found"
        else
            info "verification-result: pass found"
        fi
    fi
}

# ─── T2/T3: self-check-result required ───
check_self_check_result() {
    local sc_files
    sc_files="$(find_by_type "self-check-result")"
    if [[ -z "${sc_files}" ]]; then
        fail "No self-check-result evidence found (required for ${TIER})"
    else
        info "self-check-result evidence found"
    fi
}

# ─── T2/T3: backdating prevention via git commit ordering ───
check_commit_ordering() {
    local red_files green_files
    red_files="$(find_by_type "tdd-red")"
    green_files="$(find_by_type "tdd-green")"

    [[ -z "${red_files}" || -z "${green_files}" ]] && return

    while IFS= read -r green_file; do
        [[ -z "${green_file}" ]] && continue
        local green_sha green_slug
        green_sha="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('commit_sha',''))" "${green_file}" 2>/dev/null || echo "")"
        green_slug="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('tdd_slug',''))" "${green_file}" 2>/dev/null || echo "")"

        [[ -z "${green_sha}" || -z "${green_slug}" ]] && continue

        while IFS= read -r red_file; do
            [[ -z "${red_file}" ]] && continue
            local red_subject red_sha
            red_subject="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['subject'])" "${red_file}" 2>/dev/null || echo "")"
            red_sha="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('commit_sha',''))" "${red_file}" 2>/dev/null || echo "")"

            if [[ "${red_subject}" == *"${green_slug}"* && -n "${red_sha}" && -n "${green_sha}" ]]; then
                # Verify red_sha is ancestor of green_sha
                if git merge-base --is-ancestor "${red_sha}" "${green_sha}" 2>/dev/null; then
                    info "Commit ordering OK: ${red_sha} (red) is ancestor of ${green_sha} (green)"
                else
                    fail "Commit ordering violation: tdd-red (${red_sha}) is NOT ancestor of tdd-green (${green_sha}) for slug '${green_slug}'"
                fi
            fi
        done <<< "${red_files}"
    done <<< "${green_files}"
}

# ─── Run checks based on tier ───
info "Verifying evidence for tier ${TIER}, task ${TASK_ID}"

# Validate all JSON evidence against schema
bash "${REPO_ROOT}/.claude/skills/_shared/scripts/validate_evidence.sh" "${EVIDENCE_DIR}" || ERRORS=$((ERRORS + 1))

# T1+: TDD ordering + verification-result
check_tdd_ordering
check_verification_result

# T2/T3: additional checks
if [[ "${TIER}" == "T2" || "${TIER}" == "T3" ]]; then
    check_self_check_result
    check_commit_ordering

    # Check traceability if script exists
    TRACE_SCRIPT="${REPO_ROOT}/.claude/skills/_shared/scripts/verify_traceability.sh"
    if [[ -x "${TRACE_SCRIPT}" ]]; then
        info "Running traceability check..."
        bash "${TRACE_SCRIPT}" "${BASE_REF}" || ERRORS=$((ERRORS + 1))
    fi
fi

# ─── Report ───
if [[ ${ERRORS} -gt 0 ]]; then
    echo "verify_evidence.sh: FAILED — ${ERRORS} error(s) for tier ${TIER}" >&2
    exit 1
fi

echo "verify_evidence.sh: PASSED — tier ${TIER} evidence complete"
