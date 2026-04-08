#!/usr/bin/env bash
# Usage: gen_questions_path.sh <purpose>
# Prints docs/spec-coexist/{YYMMDDHHmmss}-{purpose}-questions.md and ensures parent dir exists.
set -euo pipefail
purpose="${1:?purpose required}"
ts="$(date +%y%m%d%H%M%S)"
dir="docs/spec-coexist"
mkdir -p "$dir"
echo "${dir}/${ts}-${purpose}-questions.md"
