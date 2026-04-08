#!/usr/bin/env bash
# Prints next zero-padded 3-digit subsystem id by scanning docs/subsystems/{id}_*.
set -euo pipefail
base="docs/subsystems"
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
