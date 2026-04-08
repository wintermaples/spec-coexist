# Negative Triggers — When the Iron Law Does Not Apply

Conformance keywords follow RFC 2119.

The Iron Law **MUST NOT** be enforced on changes fully covered by one of the clauses below. When an exclusion is used, the reason **MUST** still be recorded as `tdd-waiver` evidence citing the clause.

## §Legacy — harness gaps

- Code in a directory whose entire subtree has **zero** existing test harness AND no basic design document referencing it. Typical: pre-spec-coexist modules being migrated, `vendor/`, generated code under `gen/`.
- Once a harness is added, this clause **MUST NOT** be reused for that directory.

## §Spike — non-committed exploration

- Code in a throwaway branch **not** merged into a spec-driven branch. A commit on the main implementation branch is **not** a spike regardless of the author's label.
- Spikes **MUST** be deleted or rewritten test-first before promotion.

## §Notebook / REPL

- Jupyter notebooks (`*.ipynb`), REPL sessions, ad-hoc scripts under `scratch/` or `sandbox/`. Exploration surfaces, not production.
- A notebook imported by production code nullifies this clause for the imported symbols.

## §Config-only

- Pure configuration changes with no behavioural code: YAML, TOML, JSON, `.env.example`, `Dockerfile` metadata, CI workflow edits that do not alter build outcomes.
- Config changes that alter runtime behaviour (new feature flag default, new limit) **MUST** still be covered by a test at the layer that reads the config.

## §Docs-only

- Changes confined to Markdown, AsciiDoc, or inline docstrings/comments with no executable effect. Doctest-bearing docstrings are **not** docs-only.

## §Formatting / whitespace

- Auto-formatter runs (`gofmt`, `ruff format`, `prettier`) mechanically applied to an untouched logical change set. A format run bundled with a logic edit is **not** covered — split the commit.

## Scope limits

- These clauses are exhaustive. A rationalization not listed here is **not** an exclusion; see `rationalization-table.md` for the rebuttal.
- Multiple clauses **MAY** apply simultaneously; waivers cite all applicable clauses.
