# Code Review Protocol

## When Review is Triggered

After `verification-before-completion` (code mode) returns PASS, the agent **MUST** invoke `code-review-loop` before reporting completion to the user.

## Inputs to code-review-loop

- `WHAT_WAS_IMPLEMENTED` — short summary of the implemented feature or change.
- `PLAN_OR_REQUIREMENTS` — pointer to the approved plan and the originating spec documents.
- `BASE_SHA` — the commit immediately before this implementation began.
- `HEAD_SHA` — the current commit after verification passed.
- `DESCRIPTION` — 1–3 sentence human summary of what changed and why.

## Handling Feedback

The `code-review-loop` skill handles receiving and processing feedback internally.

## Severity Policy

| Severity | Required action |
|---|---|
| **Critical** | **MUST** be fixed before reporting completion. |
| **Important** | **MUST** be fixed before reporting completion, unless the user is explicitly asked and explicitly waives the issue. |
| **Minor** | **MAY** be deferred, but **MUST** be listed in the final report so they are not lost. |

## Re-review After Fixes

After Critical or Important fixes, the agent **SHOULD** re-run `code-review-loop` on the new `HEAD_SHA`.

## Final Report Requirement

The final report to the user **MUST** include a `Review:` line summarizing the outcome. "Implementation done" without a `Review:` line is **NOT** a valid final state.

## Pushback

If the reviewer's finding is technically incorrect, push back using `code-review-loop`'s rules (technical reasoning, reference to actual code or tests). Performative agreement with a wrong finding is not acceptable.
