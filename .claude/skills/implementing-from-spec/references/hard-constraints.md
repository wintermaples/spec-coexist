# Hard Constraints

## Input Document Checks

- If `docs/main-requirements.md` or `docs/main-basic-design.md` is missing, the skill **MUST** halt immediately. There is nothing to implement without both.
- For subsystem implementation, both `docs/subsystems/{id}_{name}/{name}-requirements.md` and `{name}-design.md` **MUST** exist; the skill **MUST** halt if either is absent.

## Plan Approval Gate

The agent **MUST NOT** begin any implementation before the user explicitly approves the plan. "I'll start and show you" is **NOT** a valid substitute for approval.

## Scope Discipline

During implementation, the agent **MUST** make minimal, focused changes — only what the spec dictates. Discovering additional work does not license silent scope expansion; surface it to the user first.

## Completion Gates (in order)

1. **verification-before-completion (code mode)** — fresh full test / type / lint run, read the full output, confirm it matches the claim. Fix and retry until the gate reports PASS with evidence. No completion claim is permitted until this gate passes.
2. **requesting-code-review + receiving-code-review** — mandatory after the verification gate passes. "Implementation done without review" is **NOT** a valid final state.
