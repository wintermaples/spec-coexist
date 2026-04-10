#!/usr/bin/env bash
# run_trigger_tests.sh — lint/validate the trigger-cases.jsonl file
#
# This is a static validator, NOT a live triggering runner. It ensures:
#   - each line is valid JSON
#   - required fields are present
#   - every referenced skill has a matching directory under .claude/skills/
#   - every skill has >= 3 positive cases and >= 1 negative case
#   - positive cases include at least one ja and one en prompt per skill
#
# A live runner (actually firing prompts against Claude and checking which
# skill triggered) is out of scope for Phase 0 and tracked in the extension
# plan §6. Until that exists, this validator is what CI should run.
#
# Usage: bash .claude/skills/_shared/tests/run_trigger_tests.sh
# Exit:  0 on success, 1 on any failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASES_FILE="${SCRIPT_DIR}/trigger-cases.jsonl"
SKILLS_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [[ ! -f "${CASES_FILE}" ]]; then
    echo "FAIL: ${CASES_FILE} not found" >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "FAIL: python3 is required" >&2
    exit 1
fi

python3 - "${CASES_FILE}" "${SKILLS_DIR}" <<'PY'
import json, os, sys
from collections import defaultdict

cases_file, skills_dir = sys.argv[1], sys.argv[2]
errors = []
per_skill = defaultdict(lambda: {"pos": 0, "neg": 0, "langs": set()})
required = {"id", "skill", "prompt", "language", "expect", "note"}
valid_expect = {"trigger", "no-trigger"}
valid_lang = {"ja", "en", "mixed"}

with open(cases_file, encoding="utf-8") as f:
    for i, line in enumerate(f, 1):
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError as e:
            errors.append(f"line {i}: invalid JSON ({e})")
            continue
        missing = required - obj.keys()
        if missing:
            errors.append(f"line {i}: missing fields {sorted(missing)}")
            continue
        if obj["expect"] not in valid_expect:
            errors.append(f"line {i}: expect must be one of {valid_expect}")
        if obj["language"] not in valid_lang:
            errors.append(f"line {i}: language must be one of {valid_lang}")
        skill = obj["skill"]
        skill_path = os.path.join(skills_dir, skill)
        if not os.path.isdir(skill_path):
            errors.append(f"line {i}: skill '{skill}' has no directory at {skill_path}")
        if obj["expect"] == "trigger":
            per_skill[skill]["pos"] += 1
            per_skill[skill]["langs"].add(obj["language"])
        else:
            per_skill[skill]["neg"] += 1

# Coverage requirements from _meta/authoring-skill:
#   positive >= 3, negative >= 1, languages include ja AND en among positives.
for skill, counts in sorted(per_skill.items()):
    if counts["pos"] < 3:
        errors.append(f"skill '{skill}': only {counts['pos']} positive cases (need >= 3)")
    if counts["neg"] < 1:
        errors.append(f"skill '{skill}': only {counts['neg']} negative cases (need >= 1)")
    langs = counts["langs"]
    if "ja" not in langs:
        errors.append(f"skill '{skill}': no ja positive case")
    if "en" not in langs:
        errors.append(f"skill '{skill}': no en positive case")

if errors:
    print("FAIL")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

total = sum(c["pos"] + c["neg"] for c in per_skill.values())
print(f"OK: {len(per_skill)} skills, {total} cases validated")
PY
