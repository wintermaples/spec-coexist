# The 1% Rule

If there is even a 1% chance that any `spec-coexist` skill applies to the user's request, the matching skill **MUST** be invoked via the `Skill` tool **before** producing any other response — including clarifying questions.

## Why it is non-negotiable

The rule is intentionally strict. The failure mode it prevents is an agent that convinces itself a skill does not apply, skips it, and then produces work that violates the spec-driven conventions the suite enforces. The cost of invoking a skill and then abandoning it is negligible; the cost of skipping it when it should have run can corrupt documentation, diverge spec from implementation, or embed bugs that slip past review.

Common rationalizations that do NOT excuse skipping:

- "The user only asked a quick question."
- "This is obviously not a spec task."
- "I'll check the skill after I answer."
- "The skill probably doesn't add anything here."

If the doubt exists at even 1%, invoke the skill.

## What happens after invocation

If you invoke a skill and it turns out not to apply, you **MAY** abandon it and respond normally. The check must happen first.

## Examples

| User message | Apply the rule? | Reason |
|---|---|---|
| "Can you explain what a basic design doc is?" | Yes — invoke `creating-basic-design` | Could lead to creating one. |
| "There's a test failure in the auth module." | Yes — invoke `systematic-debugging` | Explicitly a bug. |
| "What time is it?" | No | No conceivable spec-coexist angle. |
| "Let's implement the login feature." | Yes — invoke `implementing-from-spec` | Implementation from spec. |
| "Fix the typo in README.md." | Borderline — lean Yes | Could touch a spec document. |
