#!/usr/bin/env bash
# Thin wrapper: generates the spec-revision question file path.
set -euo pipefail
exec "$(dirname "$0")/../../_shared/scripts/gen_questions_path.sh" spec-revision
