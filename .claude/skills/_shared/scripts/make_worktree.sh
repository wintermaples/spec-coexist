#!/usr/bin/env bash
# make_worktree.sh <subsystem-id>
#
# Create ../worktrees/{id} on branch parallel/{id}, forked from the current HEAD.
# Refuses if:
#   - the repo is dirty
#   - the branch parallel/{id} already exists
#   - the target directory already exists
#
# Exit codes:
#   0 success
#   2 bad usage
#   3 dirty repo
#   4 branch or directory already exists

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: make_worktree.sh <subsystem-id>" >&2
  exit 2
fi

id="$1"
ROOT="$(git rev-parse --show-toplevel)"
PARENT="$(dirname "${ROOT}")"
TARGET="${PARENT}/worktrees/${id}"
BRANCH="parallel/${id}"

if [[ -n "$(git -C "${ROOT}" status --porcelain)" ]]; then
  echo "make_worktree.sh: refusing — repo is dirty" >&2
  exit 3
fi

if git -C "${ROOT}" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo "make_worktree.sh: branch ${BRANCH} already exists" >&2
  exit 4
fi

if [[ -e "${TARGET}" ]]; then
  echo "make_worktree.sh: target path ${TARGET} already exists" >&2
  exit 4
fi

mkdir -p "${PARENT}/worktrees"
git -C "${ROOT}" worktree add -b "${BRANCH}" "${TARGET}"

echo "created worktree: ${TARGET}"
echo "branch: ${BRANCH}"
