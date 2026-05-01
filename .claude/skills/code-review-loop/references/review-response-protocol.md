# Review response protocol

Detailed policy for `code-review-loop`. `SKILL.md` points here for severity ordering, the YAGNI check, and acknowledgment examples.

## Severity-ordered implementation

When acting on multi-item feedback, the agent **MUST** implement in this order:

1. Clarify anything unclear — stop until clarified, asking the user or the reviewer for specifics before attempting a fix.
2. Blocking issues (bugs, security, data loss).
3. Simple fixes (typos, imports, obvious errors).
4. Complex fixes (refactors, logic changes).

Use `scripts/sort_feedback_items.sh` to classify items when the ordering is non-obvious.

After each individual fix, the agent **MUST** run the relevant tests / type checks to confirm no regression before moving on.

## YAGNI check

If a reviewer recommends "implementing this properly" — more fields, more config, more abstraction — the agent **MUST** first grep the codebase for actual usage. If the feature is unused, the correct response is often to remove it rather than expand it. Surface the tradeoff to the user instead of silently adding speculative complexity.

## Acknowledging correct feedback

When feedback is correct, acknowledge with the fix itself. Examples:

- "Fixed. Added ISO date validation in `search.ts:25`."
- "Good catch — off-by-one in `indexer.ts:130`. Fixed."
- Or just: fix the code and show the diff.

No "thanks," no "great point." The code is the acknowledgment.
