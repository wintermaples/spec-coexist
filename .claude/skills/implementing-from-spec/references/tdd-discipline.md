# TDD Discipline (Iron Law)

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

This document is the TDD gate embedded inside `implementing-from-spec` and `revising`. It is not a standalone skill; it is a MUST-level procedure that those skills execute inline.

## Iron Law

**Production code MUST NOT be added, modified, or deleted unless a failing test exists in the working tree and its failure has been observed in the current session.**

"Observed" means: the test runner was actually executed, produced a non-zero exit code, and that run was recorded as RED evidence (see below). A test that is merely *believed* to fail does not satisfy the Iron Law.

## Red-Green-Refactor Loop

For every acceptance criterion extracted from the basic design, the agent **MUST** execute this loop exactly once:

1. **RED** — Write the smallest test that fails for the right reason. Run it. Capture its failure via:

   ```
   ../_shared/scripts/record_test_failure.sh <slug> -- <test command>
   ```

   The script **MUST** exit 0; if it exits 3 the test did not actually fail and the loop **MUST NOT** advance. The emitted `docs/evidence/red-*.log` path **MUST** be cited in the completion report.

2. **GREEN** — Write the minimum production code needed to make *only* that failing test pass. The diff **MUST NOT** contain code paths that are not exercised by the RED test. "While I was there I also fixed…" is a scope violation and **MUST** be rejected; surface it and get explicit user approval first.

3. **REFACTOR** — With tests green, remove duplication and tighten names. The full relevant test suite **MUST** remain green throughout. Any red observed during refactor halts refactor and reverts to RED step of a new loop.

## Test Strategy Tiers

The Iron Law applies to *every* production change, but **what counts as one "acceptance criterion that demands a RED log" depends on the declared test strategy tier** of the basic design under implementation. The tier **MUST** be declared in the basic design document (see `creating-basic-design` — field `テスト戦略 tier` / `Test strategy tier`) with a 1–3 sentence rationale. Absent declaration = `strict`.

| Tier | Applies to | RED unit (= 1 RGR loop) | Additional evidence |
|---|---|---|---|
| `strict` *(default)* | Business logic, APIs, data models, algorithms, domain rules, anything with deterministic input/output. | One failing test per acceptance criterion bullet. | None beyond `docs/evidence/red-*.log` per criterion. |
| `pipeline` | ETL, batch jobs, stream processors, notebook-derived jobs, data transforms whose correctness is judged against **representative sample inputs** rather than exhaustively. | One **characterization test** per transform *stage*, driven by a committed sample fixture. Multiple criteria about the same stage group under one RED log. | A committed sample fixture under `docs/fixtures/{stage}/` (input + expected output). No fixture → no tier. |
| `ui` | Presentational components, pages, purely visual layout, styling. | One failing **behavior / contract test** per *user interaction* (click, submit, keyboard, accessibility contract). Pure visual / layout criteria do NOT need their own RED log. | Visual criteria **MUST** be captured in `docs/evidence/ui-manual-{timestamp}.md` as a manual check list with a dated run result. |

Rules that apply to every tier:

- `pipeline` and `ui` do **not** exempt the skill from the Iron Law — they narrow the unit of observation so the loop stays honest but proportional.
- Mis-categorization is a spec defect: if during implementation the agent finds logic that looks `strict` inside a `ui` or `pipeline` subsystem, the offending bullets **MUST** be lifted to strict RGR loops for that bullet, and the mismatch reported.
- Tier selection is reviewed at basic-design review time. Changing tier after the fact **MUST** go through `revising`.
- Missing test infrastructure is still not a valid reason to downgrade. `pipeline` requires a fixture harness; `ui` requires a behavior-test runner. If neither exists, build them or waive explicitly.

## Acceptance Criteria → Loops

Before the first loop, the agent **MUST**:

1. Read the declared `test-strategy` tier from the basic design (default `strict` if absent, subject to the HALT rule in `hard-constraints.md`).
2. Extract an explicit list of acceptance criteria from the basic design and write it to `docs/acceptance/{feature}.md` (whole-system) or `docs/subsystems/{id}_{name}/acceptance.md` (subsystem), annotating each bullet with its tier-appropriate **RED unit**:
   - `strict` → one RGR loop per bullet (unchanged from previous rule).
   - `pipeline` → group bullets under their transform stage; one RGR loop per stage.
   - `ui` → group bullets under their interaction; pure-visual bullets are moved to a `Manual visual checks` subsection linked to `docs/evidence/ui-manual-*.md`.

Implementation is not "done" until every RED unit has its tier-appropriate evidence (`docs/evidence/red-*.log`, plus `docs/evidence/ui-manual-*.md` for `ui` visual bullets, plus the `docs/fixtures/{stage}/` fixture for `pipeline`) and the final GREEN state is clean.

## Waiver (residue only)

Tiers are the first-line answer to "this is hard to test". The per-instance waiver remains **only** for residue that no tier covers — e.g. a one-off ops runbook, a throw-away spike, or a pure CSS tweak in a project that has no `ui` tier declared. The agent **MAY** then skip the Iron Law after writing `docs/evidence/tdd-waiver-{timestamp}.md` containing:

- the subject,
- the concrete reason no tier + no failing test is appropriate,
- the manual verification plan that replaces it,
- explicit user acknowledgement of the waiver.

A waiver **MUST NOT** be issued silently, **MUST NOT** be issued by the agent for its own convenience, and **MUST NOT** be used as a substitute for declaring an appropriate tier. Missing test infrastructure is not a valid reason — the fix is to add the infrastructure.

## Interaction with verification-before-completion

`verification-before-completion` treats `docs/evidence/red-*.log` (or a matching `tdd-waiver-*.md`) as a required input for code-mode completion claims driven by this or `revising`. Absent evidence, the gate **MUST** HALT.
