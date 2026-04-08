# Worktree Layout

## Path

Every worktree created by this skill lives at `../worktrees/{subsystem-id}` **relative to the primary repository root**. Keeping worktrees outside the primary working tree avoids self-referential file scans and keeps `git status` in the primary clean.

## Branch

Each worktree is on branch `parallel/{subsystem-id}`, forked from the branch that was checked out in the primary at the moment `make_worktree.sh` was called (captured as the "parent branch" in the skill report).

## Naming

- `subsystem-id` is the directory name under `docs/subsystems/`, e.g. `03_payment`.
- Branch name uses the same slug: `parallel/03_payment`.
- No spaces, no uppercase letters.

## Lifecycle

1. Created by `make_worktree.sh <id>` during step 5 of the skill.
2. Populated by `implementing-from-spec` running inside it.
3. Verified by `verification-before-completion` running inside it.
4. Merged back into the parent branch by step 7 of the skill.
5. Removed by `cleanup_worktree.sh <id>` during step 8.

## Forbidden layouts

- Worktrees under the primary repo (`./worktrees/`) — causes recursive scans.
- Worktrees sharing a branch — defeats isolation.
- Worktrees whose branch name does not carry the `parallel/` prefix — breaks the cleanup safety check.
