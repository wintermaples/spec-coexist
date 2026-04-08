# TDD Discipline (Iron Law)

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

This document is the TDD gate embedded inside `implementing-from-spec` and `revising-implementation`. It is not a standalone skill; it is a MUST-level procedure that those skills execute inline.

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

## Acceptance Criteria → Loops

Before the first loop, the agent **MUST** extract an explicit list of acceptance criteria from the basic design and write it to `docs/acceptance/{feature}.md` (whole-system) or `docs/subsystems/{id}_{name}/acceptance.md` (subsystem). Each bullet in that file corresponds to exactly one Red-Green-Refactor loop. Implementation is not "done" until every bullet has a corresponding `docs/evidence/red-*.log` entry and the final GREEN state is clean.

## Waiver

If the feature genuinely resists automated testing — e.g. a pure-visual CSS tweak, an exploratory data notebook, or a manual ops runbook — the agent **MAY** skip the Iron Law **only** after writing `docs/evidence/tdd-waiver-{timestamp}.md` containing:

- the subject,
- the concrete reason a failing test cannot be written,
- the manual verification plan that replaces it,
- explicit user acknowledgement of the waiver.

A waiver **MUST NOT** be issued silently, and **MUST NOT** be issued by the agent for its own convenience. Missing test infrastructure is not a valid reason — the fix is to add the infrastructure.

## Interaction with verification-before-completion

`verification-before-completion` treats `docs/evidence/red-*.log` (or a matching `tdd-waiver-*.md`) as a required input for code-mode completion claims driven by this or `revising-implementation`. Absent evidence, the gate **MUST** HALT.
