#!/usr/bin/env bash
# resolve_subsystem_path.sh <qualified-id>
#
# Convert a ~-separated qualified identifier back to a filesystem path.
#
# Examples:
#   resolve_subsystem_path.sh 001_auth
#     → docs/subsystems/001_auth
#
#   resolve_subsystem_path.sh 001_common~002_notification
#     → docs/subsystems/001_common/subsystems/002_notification
#
#   resolve_subsystem_path.sh 001_a~002_b~003_c
#     → docs/subsystems/001_a/subsystems/002_b/subsystems/003_c
set -euo pipefail
qid="${1:?qualified subsystem id required}"
echo "docs/subsystems/${qid//\~//subsystems/}"
