# Review Response Protocol

Detailed policy for `receiving-code-review`. The SKILL.md orchestrator points here for severity ordering, the YAGNI check, and acknowledgment examples.

## Severity-Ordered Implementation

When acting on multi-item feedback, the agent **MUST** implement in this order:

1. Clarify anything unclear (stop until clarified — see SKILL.md "Handling Unclear Feedback").
2. Blocking issues (bugs, security, data loss).
3. Simple fixes (typos, imports, obvious errors).
4. Complex fixes (refactors, logic changes).

Use `scripts/sort_feedback_items.sh` to classify items when the ordering is non-obvious.

After each individual fix, the agent **MUST** run the relevant tests / type checks to confirm no regression before moving on.

## YAGNI Check

If a reviewer recommends "implementing this properly" — more fields, more config, more abstraction — the agent **MUST** first grep the codebase for actual usage. If the feature is unused, the correct response is often to remove it, not to expand it. Surface the tradeoff to the user rather than silently adding speculative complexity.

## Acknowledging Correct Feedback

When feedback is correct, acknowledge with the fix itself. Examples:

- "Fixed. Added ISO date validation in `search.ts:25`."
- "Good catch — off-by-one in `indexer.ts:130`. Fixed."
- Or just: fix the code and show the diff.

No "thanks," no "great point." The code is the acknowledgment.
