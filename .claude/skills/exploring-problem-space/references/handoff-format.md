# Handoff Memo Format

The memo written in step 6 of `exploring-problem-space` lives at `docs/handoff/exploration-{YYYY-MM-DD}.md` and **MUST** contain these sections in this order.

```markdown
# Exploration Handoff — {short topic}

Date: {YYYY-MM-DD}
Author: {agent on behalf of {user}}

## Chosen Problem Statement
{one sentence, in the form "The real problem is X, causing Y."}

## Why This One
{why it won over the alternatives — expected information gain, falsification cost, stakeholder urgency}

## Rejected Alternatives
- H{n}: {hypothesis} — rejected because {reason}
- ...

## Stakeholders
- {who feels the pain}
- {who decides}
- {who pays}

## Constraints
- Time: {...}
- Budget: {...}
- Compliance / policy: {...}
- Technical: {...}

## Open Questions for Requirements Phase
- {question that `creating-requirements` must answer}
- ...

## Next Step
Invoke `spec-coexist:creating-requirements` with this memo as input.
```

## Rules

- **MUST** contain all sections, even when a section is `(none)`. Empty sections are intentional evidence that the agent considered the topic and found nothing.
- **MUST NOT** include draft user stories or acceptance criteria — those belong in `creating-requirements`.
- The chosen problem statement **MUST** be a single sentence. If it needs a paragraph, divergence was insufficient.
- The final `Review:` line of the skill report **MUST** reference the memo by path.
