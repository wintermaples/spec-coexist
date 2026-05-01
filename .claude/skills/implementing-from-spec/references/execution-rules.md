# Execution Rules

These rules govern how the agent executes an approved implementation plan.

## Step-by-Step Discipline

1. Work step-by-step, in the order defined in the approved plan. Do not collapse multiple steps into one pass.
2. Every production-code step **MUST** begin with a Red-Green-Refactor loop per `references/tdd-discipline.md`. RED evidence is captured with `_shared/scripts/record_test_failure.sh` and written to `docs/evidence/red-*.log`.
3. After each meaningful step, the agent **MUST** run the relevant tests, type checks, and linters for the changed area. A step is not complete until its local verification passes.
4. Do **NOT** defer all testing to the end. Catching failures step-by-step is faster than debugging a fully assembled system.

## Plan Deviation Handling

If reality diverges from the plan during execution (unexpected file structure, conflicting dependency, spec ambiguity revealed by code):

1. **Stop** — do not continue silently.
2. **Explain** to the user exactly what diverged and why.
3. **Update the plan** to reflect the new understanding and present the revised plan.
4. Wait for the user to acknowledge before continuing.

"It turned out to be slightly different but I handled it" is **NOT** acceptable. Deviations are surfaced, not buried.

## Scope Discipline

**MUST NOT** silently expand scope. If additional necessary work is discovered during execution, surface it explicitly and get the user's acknowledgement before doing it.

## End-of-Implementation Check

At the end of all steps, before invoking the verification gate, the agent **MUST** confirm:

- Every step in the approved plan was executed.
- No temporary / debug code was left in.
- No placeholder comments like `TODO`, `FIXME`, `HACK`, or `XXX` were introduced without the user's knowledge.
