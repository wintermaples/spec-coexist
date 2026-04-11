# Consolidation

Step 7 of `parallelizing-subsystem-work` merges each worktree's branch back into the parent branch. The isolation check in `isolation-rules.md` guarantees there should be no conflicts; any conflict is a **bug in the isolation check** and **MUST** be recorded as such.

## Order

1. Determine merge order by topological sort of the consolidation graph (usually empty — independent sets have no edges). If the graph has edges, the set was not actually independent; abort.
2. Merge in a deterministic order (ascending by `subsystem-id`) so that conflict reports are reproducible across runs.
3. When subsystems have **consumer relationships** (A provides an interface that B consumes, even if they passed the independence check because no shared files exist), merge the **provider first**. This ensures the integration test suite can validate the provider's API surface before the consumer's code references it.

### Topological sort procedure

```
1. Read edges from subsystem_deps.sh output.
2. For each subsystem in the independent set, collect its
   transitive "provides" relationships from the design doc's
   `Provides-to:` frontmatter (inverse of `Depends-on:`).
3. Build a DAG: edge from A→B means "merge A before B".
4. If the DAG has a cycle, the set is not independent — HALT.
5. Topological sort the DAG. Ties broken by ascending subsystem-id.
6. If no edges exist (typical), fall back to ascending subsystem-id.
```

### Pre-consolidation checkpoint

Before merging the first branch, record the current HEAD:

```bash
PRE_CONSOLIDATION_SHA="$(git rev-parse HEAD)"
```

This SHA is required by the rollback procedure in `partial-failure.md`.

## Merge mode

- Use `git merge --no-ff parallel/{id}` so that each integration stays visible as a merge commit. Fast-forward would hide the parallel structure from later archaeology.
- **MUST NOT** use `git merge --squash`. Squashing destroys the per-worktree `verification-before-completion` evidence linkage.

## Runtime conflict detection

After all worktrees complete but **before** starting merges, run:

```bash
_shared/scripts/detect_worktree_conflicts.sh
```

If it reports overlapping files, the isolation check had a false negative. **HALT** and record the conflict in `docs/evidence/parallel-conflict-{YYYY-MM-DD}.md` before attempting any merge.

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
