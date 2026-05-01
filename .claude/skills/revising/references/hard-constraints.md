# Hard Constraints — revising

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke any `superpowers:*` skill — brainstorming and plan execution are embedded. It **MUST** invoke the project-local `code-review-loop`.

## Document existence

- If either `docs/main-requirements.md` or `docs/main-basic-design.md` is missing, the skill **MUST** halt immediately.
- For subsystem revisions, both the subsystem's `{name}-requirements.md` and `{name}-design.md` **MUST** exist inside the subsystem directory (which may be nested, e.g. `docs/subsystems/{parent_id}_{parent}/subsystems/{id}_{name}/`). If either is missing, the skill **MUST** halt.

## Diff inspection

Before brainstorming, the agent **MUST** read recent diffs of the spec documents — for example, `git log -p -- docs/main-requirements.md docs/main-basic-design.md`. Skipping this step makes it impossible to know which code changes are actually required.

## TDD Iron Law

Every production-code change driven by this skill **MUST** begin with a failing test that is both observed in the current session and recorded via `../../_shared/scripts/record_test_failure.sh` (which writes to `docs/evidence/red-*.log`). See `../../implementing-from-spec/references/tdd-discipline.md` — that document is authoritative for both skills, so do not duplicate it. The only legal bypass is an explicitly-acknowledged `docs/evidence/tdd-waiver-*.md`. If neither artifact exists for the claimed work, `verification-before-completion` **MUST** HALT.

## Verification gate

Once the implementation revision is applied, and **before** anything else, the agent **MUST** pass through `verification-before-completion` (code mode) — fresh full tests, type checks, linters, and a full read of the output.

## Review gate

After the verification gate passes, the agent **MUST** invoke `code-review-loop` **before** reporting completion. See `mandatory-code-review.md`.
