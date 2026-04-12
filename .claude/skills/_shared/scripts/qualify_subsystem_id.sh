#!/usr/bin/env bash
# qualify_subsystem_id.sh <subsystem-dir-path>
#
# Convert a subsystem directory path to a ~-separated qualified identifier.
#
# Examples:
#   qualify_subsystem_id.sh docs/subsystems/001_auth
#     → 001_auth
#
#   qualify_subsystem_id.sh docs/subsystems/001_common/subsystems/002_notification
#     → 001_common~002_notification
#
#   qualify_subsystem_id.sh docs/subsystems/001_a/subsystems/002_b/subsystems/003_c
#     → 001_a~002_b~003_c
set -euo pipefail
path="${1:?subsystem directory path required}"
# Strip trailing slash
path="${path%/}"
# Strip leading docs/subsystems/
path="${path#docs/subsystems/}"
# Replace /subsystems/ with ~
echo "${path//\/subsystems\//"~"}"
