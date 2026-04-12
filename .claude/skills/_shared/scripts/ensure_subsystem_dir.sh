#!/usr/bin/env bash
# Usage: ensure_subsystem_dir.sh <subsystem-name> [parent-dir]
#   parent-dir: directory containing (or that will contain) a subsystems/ folder.
#               Defaults to "docs". For nested subsystems, pass the parent
#               subsystem path, e.g. "docs/subsystems/001_common-platform".
#
# Allocates a new id under {parent-dir}/subsystems/ and creates the directory.
# Prints the created path.
#
# The subsystem name MUST NOT contain the '~' character (reserved as the
# qualified-ID separator).
set -euo pipefail
name="${1:?subsystem-name required}"
parent="${2:-docs}"

if [[ "$name" == *"~"* ]]; then
  echo "ensure_subsystem_dir.sh: subsystem name must not contain '~'" >&2
  exit 2
fi

here="$(cd "$(dirname "$0")" && pwd)"
id="$("$here/next_subsystem_id.sh" "$parent")"
dir="${parent}/subsystems/${id}_${name}"
mkdir -p "$dir"
echo "$dir"
