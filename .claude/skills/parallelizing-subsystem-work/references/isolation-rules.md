# Isolation Rules

The value of `parallelizing-subsystem-work` is this decision procedure. If the procedure is weak, parallel execution silently corrupts work.

## Two subsystems A and B MAY run in parallel if and only if

1. **No shared writable files.** The union of files that A's design says it will modify and the union of files that B's design says it will modify **MUST** be disjoint.
2. **No shared main-* files.** Neither A nor B's design names any file matching `docs/main-*.md` or the root-level shared configuration files (`package.json`, `pyproject.toml`, `go.mod`, database migration directories). Root shared files are a special case of rule 1, listed separately because subsystem authors routinely forget them.
3. **No declared dependency.** A's design **MUST NOT** mention B as a prerequisite, and vice versa. The dependency graph is read from `_shared/scripts/subsystem_deps.sh`, which recursively scans all `*-design.md` files under `docs/subsystems/` (including nested subsystems) for `Depends-on:` front-matter lines.
4. **No shared public API signature.** If A adds a function that B is expected to consume, they are sequential, not parallel, even if the files differ.

All four conditions **MUST** hold. Failing any one disqualifies the pair.

## How to pick the set

Given N ready subsystems:

1. Build the conflict graph: nodes are subsystems, an edge means the pair fails any of the four conditions above.
2. The valid parallel set is the **largest independent set** in this graph containing no `main-*` violators.
3. Prefer sets of size 2–4. Beyond 4, human review of consolidation becomes the bottleneck and the theoretical speedup evaporates.
4. If the largest independent set has size 1, **HALT** — parallelization is not the right tool here.

## Why HALT instead of degrade

An agent that "parallelizes what it can and sequences the rest" is hard to audit and easy to misconfigure. This skill halts on any ambiguity so the user's decision is recorded in the conversation log.

## Repository assumption

This ruleset assumes the repository uses the `spec-coexist` subsystem layout (`docs/subsystems/{id}_{name}/{name}-design.md`), which supports nested subsystems (e.g. `docs/subsystems/{parent_id}_{parent}/subsystems/{id}_{name}/{name}-design.md`). Nested subsystems use `~`-separated qualified IDs (e.g. `001_common~001_notification`) for flat identifiers in edge lists, evidence directories, and changelog filenames. For git branch names, `~` is replaced with `--` (e.g. `parallel/001_common--001_notification`) since git refs cannot contain `~`. Porting to a different layout **MUST** begin by rewriting this file.
