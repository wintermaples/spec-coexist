#!/usr/bin/env bash
# Usage: sort_feedback_items.sh <feedback-file>
# Classifies review feedback items by severity heuristics and prints them in
# implementation order: BLOCKING → SIMPLE → COMPLEX → OTHER.
set -euo pipefail

file="${1:?Usage: sort_feedback_items.sh <feedback-file>}"
[[ -f "$file" ]] || { echo "ERROR: file not found: $file" >&2; exit 1; }

declare -a blocking=() simple=() complex=() other=()

BLOCKING_RE='(bug|security|crash|data.loss|broken|exploit|injection|overflow|null.deref|corrupt)'
SIMPLE_RE='(typo|import|whitespace|rename|obvious|formatting|unused.variable|missing.semicolon)'
COMPLEX_RE='(refactor|redesign|abstraction|architecture|logic|restructure|rewrite|decouple|extract)'

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "${line// }" ]] && continue
  lower="${line,,}"
  if   [[ "$lower" =~ $BLOCKING_RE ]]; then blocking+=("$line")
  elif [[ "$lower" =~ $SIMPLE_RE   ]]; then simple+=("$line")
  elif [[ "$lower" =~ $COMPLEX_RE  ]]; then complex+=("$line")
  else other+=("$line")
  fi
done < "$file"

print_group() {
  local label="$1"; shift
  local items=("$@")
  if [[ ${#items[@]} -gt 0 ]]; then
    echo "### $label"
    for item in "${items[@]}"; do echo "  - $item"; done
    echo
  fi
}

print_group "BLOCKING (implement first)" "${blocking[@]+"${blocking[@]}"}"
print_group "SIMPLE (implement second)"  "${simple[@]+"${simple[@]}"}"
print_group "COMPLEX (implement third)"  "${complex[@]+"${complex[@]}"}"
print_group "OTHER (implement last)"     "${other[@]+"${other[@]}"}"
