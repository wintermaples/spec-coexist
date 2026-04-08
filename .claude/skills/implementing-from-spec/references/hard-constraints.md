# Hard Constraints

## Input Document Checks

- If `docs/main-requirements.md` or `docs/main-basic-design.md` is missing, the skill **MUST** halt immediately. There is nothing to implement without both.
- For subsystem implementation, both `docs/subsystems/{id}_{name}/{name}-requirements.md` and `{name}-design.md` **MUST** exist; the skill **MUST** halt if either is absent.

## Plan Approval Gate

The agent **MUST NOT** begin any implementation before the user explicitly approves the plan. "I'll start and show you" is **NOT** a valid substitute for approval.

## Scope Discipline

During implementation, the agent **MUST** make minimal, focused changes — only what the spec dictates. Discovering additional work does not license silent scope expansion; surface it to the user first.

## TDD Iron Law

Every production change **MUST** be driven by a failing test observed in the current session and recorded via `_shared/scripts/record_test_failure.sh`. See `references/tdd-discipline.md`. The *unit* of RED observation is set by the basic design's declared **test strategy tier** (`strict` / `pipeline` / `ui`); see `references/tdd-discipline.md` §Test Strategy Tiers. The only legal bypass is a `docs/evidence/tdd-waiver-*.md` file with explicit user acknowledgement, reserved for residue no tier covers. `verification-before-completion` **MUST** HALT if the tier-appropriate evidence (`docs/evidence/red-*.log` plus any tier-required artifacts) or a matching waiver is absent for the claimed work.

## Test Strategy Tier Declaration

The basic design document **MUST** declare a `test-strategy` tier (one of `strict`, `pipeline`, `ui`) with a 1–3 sentence rationale. Absent declaration = `strict`. `implementing-from-spec` **MUST** HALT before step 5 if the target basic design lacks the declaration **and** the domain is unambiguously UI-heavy (contains §5 画面設計 with non-empty screen definitions, or equivalent `ui/` / `components/` paths in §6 Files Modified) or pipeline-heavy (contains §7 バッチ設計 with non-empty batch definitions, or `etl/` / `pipelines/` paths). HALT message **MUST** route the user to `revising-spec` to add the declaration — it **MUST NOT** be added silently by the implementer.

## Completion Gates (in order)

1. **TDD evidence present** — at least one `docs/evidence/red-*.log` per acceptance criterion, or a documented waiver. No RED, no GREEN.
2. **verification-before-completion (code mode)** — fresh full test / type / lint run, read the full output, confirm it matches the claim. Fix and retry until the gate reports PASS with evidence. No completion claim is permitted until this gate passes.
3. **requesting-code-review + receiving-code-review** — mandatory after the verification gate passes. "Implementation done without review" is **NOT** a valid final state.
