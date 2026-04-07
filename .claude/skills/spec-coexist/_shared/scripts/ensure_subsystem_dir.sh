#!/usr/bin/env bash
# Usage: ensure_subsystem_dir.sh <subsystem-name>
# Allocates a new id and creates docs/subsystems/{id}_{name}/, prints the path.
set -euo pipefail
name="${1:?subsystem-name required}"
here="$(cd "$(dirname "$0")" && pwd)"
id="$("$here/next_subsystem_id.sh")"
dir="docs/subsystems/${id}_${name}"
mkdir -p "$dir"
echo "$dir"
