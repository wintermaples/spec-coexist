#!/usr/bin/env bash
# subsystem_deps.sh — print a dependency edge list for subsystems under docs/subsystems/.
#
# Output format (one edge per line, tab-separated):
#   {from-id}\t{to-id}
#
# Also prints self-edges of the form:
#   {from-id}\tMAIN
# whenever a subsystem's design mentions a shared docs/main-*.md file.
#
# A subsystem's dependencies are read from its *-design.md frontmatter or body
# via lines of the form:
#   Depends-on: {other-id}[, {other-id}...]
#
# Exit 0 always if docs/subsystems/ exists, else 2.

set -euo pipefail

ROOT="${ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SUBS="${ROOT}/docs/subsystems"

if [[ ! -d "${SUBS}" ]]; then
  echo "subsystem_deps.sh: docs/subsystems/ not found under ${ROOT}" >&2
  exit 2
fi

shopt -s nullglob
for dir in "${SUBS}"/*/; do
  id="$(basename "${dir}")"
  design="$(ls "${dir}"*-design.md 2>/dev/null | head -n1 || true)"
  [[ -z "${design}" ]] && continue

  # Depends-on line(s)
  while IFS= read -r line; do
    # strip "Depends-on:" prefix, split on commas, trim
    deps="${line#*:}"
    IFS=',' read -ra parts <<<"${deps}"
    for p in "${parts[@]}"; do
      dep="$(echo "${p}" | tr -d '[:space:]')"
      [[ -z "${dep}" ]] && continue
      printf '%s\t%s\n' "${id}" "${dep}"
    done
  done < <(grep -E '^[[:space:]]*Depends-on:' "${design}" || true)

  # main-* references
  if grep -Eq '(docs/)?main-[a-z-]+\.md' "${design}"; then
    printf '%s\tMAIN\n' "${id}"
  fi
done
