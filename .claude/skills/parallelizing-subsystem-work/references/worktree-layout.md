# Worktree Layout

## Path

Every worktree this skill creates lives at `../worktrees/{subsystem-id}`, **relative to the primary repository root**. Placing worktrees outside the primary working tree avoids self-referential file scans and keeps `git status` clean in the primary.

## Branch

Each worktree sits on branch `parallel/{subsystem-id}`. The branch is forked from whatever branch was checked out in the primary repository at the moment `make_worktree.sh` was called (captured as the "parent branch" in the skill report).

## Naming

- **Flat (top-level) subsystems**: `subsystem-id` is the directory name under `docs/subsystems/` (e.g. `03_payment`). Branch name: `parallel/03_payment`.
- **Nested subsystems**: `subsystem-id` is a `~`-separated qualified identifier joining each `{id}_{name}` segment from root to leaf — e.g. `001_common~001_notification` for `docs/subsystems/001_common/subsystems/001_notification/`. Branch name: `parallel/001_common--001_notification` (`~` is replaced with `--` because git refs cannot contain `~`).
- Use `qualify_subsystem_id.sh <path>` to compute the qualified ID from a filesystem path, and `resolve_subsystem_path.sh <qualified-id>` for the reverse.
- No spaces and no uppercase letters.

## Lifecycle

1. **Create** with `make_worktree.sh <id>` (step 5 of the skill).
2. **Populate** by running `implementing-from-spec` inside it.
3. **Verify** by running `verification-before-completion` inside it.
4. **Merge** back into the parent branch (step 7 of the skill).
5. **Remove** with `cleanup_worktree.sh <id>` (step 8).

## Forbidden layouts

- Worktrees placed under the primary repo (`./worktrees/`) — these cause recursive scans.
- Worktrees that share a branch — sharing defeats isolation.
- Worktrees whose branch name omits the `parallel/` prefix — breaks the cleanup safety check.
