#!/usr/bin/env bash
# detect_worktree_conflicts.sh
#
# Detect file-level conflicts between active parallel worktrees.
# Compares each worktree's changed files (vs. its fork point) against every
# other worktree. Reports overlapping files that would cause merge conflicts.
#
# Usage:
#   detect_worktree_conflicts.sh              # check all active parallel/* worktrees
#   detect_worktree_conflicts.sh id1 id2 ...  # check only named subsystem ids
#
# Output (tab-separated, one conflict per line):
#   {id-A}\t{id-B}\t{conflicting-file}
#
# Exit codes:
#   0  no conflicts detected
#   1  conflicts detected (printed to stdout)
#   2  bad usage or no worktrees found

set -euo pipefail

ROOT="${ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PARENT="$(dirname "${ROOT}")"
WT_BASE="${PARENT}/worktrees"

if [[ ! -d "${WT_BASE}" ]]; then
  echo "detect_worktree_conflicts.sh: no worktrees directory at ${WT_BASE}" >&2
  exit 2
fi

# Collect subsystem ids — either from args or by scanning worktrees/
ids=()
if [[ $# -gt 0 ]]; then
  ids=("$@")
else
  for d in "${WT_BASE}"/*/; do
    [[ -d "${d}" ]] || continue
    ids+=("$(basename "${d}")")
  done
fi

if [[ ${#ids[@]} -lt 2 ]]; then
  echo "detect_worktree_conflicts.sh: need at least 2 worktrees, found ${#ids[@]}" >&2
  exit 2
fi

# For each worktree, compute the set of files changed since fork point
declare -A changed_files  # id -> newline-separated file list

for id in "${ids[@]}"; do
  wt="${WT_BASE}/${id}"
  branch="parallel/${id}"

  if [[ ! -d "${wt}" ]]; then
    echo "detect_worktree_conflicts.sh: worktree ${wt} does not exist, skipping" >&2
    continue
  fi

  # Find the fork point (merge base with the parent branch)
  fork_point="$(git -C "${wt}" merge-base HEAD "$(git -C "${wt}" rev-parse --abbrev-ref "${branch}@{upstream}" 2>/dev/null || git -C "${ROOT}" rev-parse HEAD)" 2>/dev/null || git -C "${ROOT}" rev-parse HEAD)"

  # List files changed in this worktree since fork
  files="$(git -C "${wt}" diff --name-only "${fork_point}" HEAD 2>/dev/null || true)"

  # Also include uncommitted changes
  uncommitted="$(git -C "${wt}" diff --name-only HEAD 2>/dev/null || true)"
  staged="$(git -C "${wt}" diff --name-only --cached 2>/dev/null || true)"

  # Combine and deduplicate
  all_files="$(printf '%s\n%s\n%s' "${files}" "${uncommitted}" "${staged}" | sort -u | grep -v '^$' || true)"
  changed_files["${id}"]="${all_files}"
done

# Pairwise comparison
conflicts_found=0
checked_ids=()
for id in "${ids[@]}"; do
  [[ -n "${changed_files[${id}]+x}" ]] || continue
  checked_ids+=("${id}")
done

for ((i=0; i<${#checked_ids[@]}; i++)); do
  for ((j=i+1; j<${#checked_ids[@]}; j++)); do
    id_a="${checked_ids[$i]}"
    id_b="${checked_ids[$j]}"

    files_a="${changed_files[${id_a}]}"
    files_b="${changed_files[${id_b}]}"

    [[ -z "${files_a}" || -z "${files_b}" ]] && continue

    # Find intersection
    overlap="$(comm -12 <(echo "${files_a}" | sort) <(echo "${files_b}" | sort) || true)"

    if [[ -n "${overlap}" ]]; then
      while IFS= read -r f; do
        [[ -z "${f}" ]] && continue
        printf '%s\t%s\t%s\n' "${id_a}" "${id_b}" "${f}"
        conflicts_found=1
      done <<< "${overlap}"
    fi
  done
done

if [[ "${conflicts_found}" -eq 1 ]]; then
  exit 1
else
  echo "No file conflicts detected between ${#checked_ids[@]} worktrees."
  exit 0
fi
