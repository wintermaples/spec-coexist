# Hard Constraints — revising-implementation

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke any `superpowers:*` skill. Brainstorming and plan execution are embedded. It **MUST** invoke project-local `requesting-code-review` and `receiving-code-review`.

## Document Existence

- If `docs/main-requirements.md` or `docs/main-basic-design.md` is missing, the skill **MUST** halt immediately.
- For subsystem revisions, both `docs/subsystems/{id}_{name}/{name}-requirements.md` and `{name}-design.md` **MUST** exist; otherwise **MUST** halt.

## Diff Inspection

The agent **MUST** read recent diffs of the spec documents (e.g. `git log -p -- docs/main-requirements.md docs/main-basic-design.md`) before brainstorming. Without this step it is impossible to know which code changes are required.

## TDD Iron Law

Every production-code change driven by this skill **MUST** begin with a failing test observed in the current session and recorded via `../../_shared/scripts/record_test_failure.sh` (written to `docs/evidence/red-*.log`). See `../../implementing-from-spec/references/tdd-discipline.md` — that document is authoritative for both skills; do not duplicate it. The only legal bypass is an explicitly-acknowledged `docs/evidence/tdd-waiver-*.md`. `verification-before-completion` **MUST** HALT if neither exists for the claimed work.

## Verification Gate

After the implementation revision is applied, the agent **MUST** pass through `verification-before-completion` (code mode) — fresh full tests, type checks, linters, full output read — **before** anything else.

## Review Gate

After the verification gate passes, the agent **MUST** invoke `requesting-code-review` and handle the result via `receiving-code-review` **before** reporting completion. See `mandatory-code-review.md`.
