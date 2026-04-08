#!/usr/bin/env bash
# cleanup_worktree.sh <subsystem-id>
#
# Remove ../worktrees/{id} and delete branch parallel/{id}.
# Refuses if:
#   - the worktree has uncommitted changes
#   - the branch has commits not yet merged into the parent branch
#
# Use --force ONLY after an explicit user confirmation recorded in the
# conversation log; pass via env CLEANUP_FORCE=1.
#
# Exit codes:
#   0 success
#   2 bad usage
#   3 unmerged or dirty (refuse without force)

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: cleanup_worktree.sh <subsystem-id>" >&2
  exit 2
fi

id="$1"
ROOT="$(git rev-parse --show-toplevel)"
PARENT="$(dirname "${ROOT}")"
TARGET="${PARENT}/worktrees/${id}"
BRANCH="parallel/${id}"
FORCE="${CLEANUP_FORCE:-0}"

if [[ ! -d "${TARGET}" ]]; then
  echo "cleanup_worktree.sh: ${TARGET} does not exist, nothing to do"
  exit 0
fi

if [[ -n "$(git -C "${TARGET}" status --porcelain 2>/dev/null || true)" ]]; then
  if [[ "${FORCE}" != "1" ]]; then
    echo "cleanup_worktree.sh: refusing — worktree has uncommitted changes. Re-run with CLEANUP_FORCE=1 only after user confirmation." >&2
    exit 3
  fi
fi

# Check that branch is merged somewhere
if git -C "${ROOT}" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  if ! git -C "${ROOT}" branch --merged | grep -qE "^[ *]+${BRANCH}$"; then
    if [[ "${FORCE}" != "1" ]]; then
      echo "cleanup_worktree.sh: refusing — ${BRANCH} is not merged into any checked-out branch. Re-run with CLEANUP_FORCE=1 only after user confirmation." >&2
      exit 3
    fi
  fi
fi

if [[ "${FORCE}" == "1" ]]; then
  git -C "${ROOT}" worktree remove --force "${TARGET}"
  git -C "${ROOT}" branch -D "${BRANCH}" 2>/dev/null || true
else
  git -C "${ROOT}" worktree remove "${TARGET}"
  git -C "${ROOT}" branch -d "${BRANCH}" 2>/dev/null || true
fi

echo "cleaned: ${TARGET} and ${BRANCH}"
