# Isolation Rules

The decision procedure below **is** the value of `parallelizing-subsystem-work`. If the procedure is weak, parallel execution silently corrupts work.

## Parallel-safety conditions

Two subsystems A and B **MAY** run in parallel **if and only if** all four conditions hold. Failing any single condition disqualifies the pair.

1. **No shared writable files.** The set of files A's design says it will modify and the set of files B's design says it will modify **MUST** be disjoint.
2. **No shared main-\* files.** Neither A nor B's design names any file matching `docs/main-*.md`, nor any root-level shared configuration file (`package.json`, `pyproject.toml`, `go.mod`, database migration directories). Strictly, this is a special case of rule 1; it is listed separately because subsystem authors routinely forget root files.
3. **No declared dependency.** A's design **MUST NOT** name B as a prerequisite, and vice versa. The dependency graph is produced by `_shared/scripts/subsystem_deps.sh`, which recursively scans every `*-design.md` under `docs/subsystems/` (including nested subsystems) for `Depends-on:` front-matter lines.
4. **No shared public API signature.** If A adds a function that B is expected to consume, the pair is sequential, not parallel — even when the files differ.

## Selecting the parallel set

Given N ready subsystems:

1. Build the **conflict graph**: nodes are subsystems; an edge connects any pair that fails one or more of the four conditions above.
2. The valid parallel set is the **largest independent set** in this graph that contains no `main-*` violators.
3. Prefer sets of size 2–4. Beyond 4, human review of consolidation becomes the bottleneck and the theoretical speedup evaporates.
4. If the largest independent set has size 1, **HALT** — parallelization is not the right tool for this situation.

## Why HALT instead of degrade

An agent that "parallelizes what it can and sequences the rest" is hard to audit and easy to misconfigure. This skill halts on any ambiguity, so the user's decision is recorded in the conversation log.

## Repository assumption

This ruleset assumes the repository uses the `spec-coexist` subsystem layout (`docs/subsystems/{id}_{name}/{name}-design.md`), which also supports nested subsystems (for example, `docs/subsystems/{parent_id}_{parent}/subsystems/{id}_{name}/{name}-design.md`).

- **Flat identifiers** for edge lists, evidence directories, and changelog filenames use `~`-separated qualified IDs (e.g. `001_common~001_notification`).
- **Git branch names** replace `~` with `--` (e.g. `parallel/001_common--001_notification`) because git refs cannot contain `~`.

Porting to a different layout **MUST** begin by rewriting this file.
