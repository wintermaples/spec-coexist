# Consolidation

Step 7 of `parallelizing-subsystem-work` merges each worktree's branch back into the parent branch. The isolation check in `isolation-rules.md` guarantees there should be no conflicts; any conflict is a **bug in the isolation check** and **MUST** be recorded as such.

## Order

1. Determine merge order by topological sort of the consolidation graph (usually empty — independent sets have no edges). If the graph has edges, the set was not actually independent; abort.
2. Merge in a deterministic order (ascending by `subsystem-id`) so that conflict reports are reproducible across runs.

## Merge mode

- Use `git merge --no-ff parallel/{id}` so that each integration stays visible as a merge commit. Fast-forward would hide the parallel structure from later archaeology.
- **MUST NOT** use `git merge --squash`. Squashing destroys the per-worktree `verification-before-completion` evidence linkage.

## Conflict handling

If a merge reports a conflict:

1. **HALT** the skill.
2. Write `docs/evidence/parallel-conflict-{YYYY-MM-DD}.md` containing: the conflicting subsystem pair, the exact files, the line ranges, and a one-line hypothesis of which rule in `isolation-rules.md` should have caught it.
3. Return control to the user. Do not attempt auto-resolution — the conflict is diagnostic.

## Post-merge

After all merges succeed:

1. Run the parent-branch test suite once. If it fails, this is a different diagnostic — the isolation was fine but the subsystems together violate an integration invariant. Record as `docs/evidence/parallel-integration-failure-{YYYY-MM-DD}.md`.
2. Invoke `spec-coexist:verification-before-completion` on the parent branch as a single aggregate run.
3. Only then proceed to `cleanup_worktree.sh`.
