#!/usr/bin/env bash
# Prints next zero-padded 3-digit subsystem id by scanning {parent}/subsystems/{id}_*.
#
# Usage: next_subsystem_id.sh [parent-dir]
#   parent-dir: directory containing a subsystems/ folder (default: "docs").
#               For nested subsystems, pass the parent subsystem path,
#               e.g. "docs/subsystems/001_common-platform".
set -euo pipefail
parent="${1:-docs}"
base="${parent}/subsystems"
max=0
if [ -d "$base" ]; then
  for d in "$base"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    id="${name%%_*}"
    if [[ "$id" =~ ^[0-9]+$ ]]; then
      n=$((10#$id))
      (( n > max )) && max=$n
    fi
  done
fi
next=$((max + 1))
printf "%03d\n" "$next"
