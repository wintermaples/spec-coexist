#!/usr/bin/env bash
# subsystem_deps.sh — print a dependency edge list for all subsystems under docs/subsystems/,
# including nested subsystems (e.g. docs/subsystems/001_common/subsystems/001_notification/).
#
# Output format (one edge per line, tab-separated):
#   {qualified-from-id}\t{qualified-to-id}
#
# Also prints self-edges of the form:
#   {qualified-from-id}\tMAIN
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
HERE="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "${SUBS}" ]]; then
  echo "subsystem_deps.sh: docs/subsystems/ not found under ${ROOT}" >&2
  exit 2
fi

# Recursively find all subsystem directories (directories inside any subsystems/ folder
# that match the {id}_{name} pattern).
find "${ROOT}/docs" -type d -name "subsystems" | while IFS= read -r subs_dir; do
  shopt -s nullglob
  for dir in "${subs_dir}"/*/; do
    [ -d "$dir" ] || continue

    # Compute qualified ID from the directory path
    rel_path="${dir#"${ROOT}"/}"
    rel_path="${rel_path%/}"
    qid="$("${HERE}/qualify_subsystem_id.sh" "${rel_path}")"

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
        printf '%s\t%s\n' "${qid}" "${dep}"
      done
    done < <(grep -E '^[[:space:]]*Depends-on:' "${design}" || true)

    # main-* references
    if grep -Eq '(docs/)?main-[a-z-]+\.md' "${design}"; then
      printf '%s\tMAIN\n' "${qid}"
    fi
  done
done
