# Mandatory Code Review — revising-implementation

Skipping review is **NOT** permitted even for small revisions — small changes are exactly where silent regressions hide.

## Invocation

After the verification gate passes, the agent **MUST** invoke `requesting-code-review` with:

- `WHAT_WAS_IMPLEMENTED` — summary of the revision.
- `PLAN_OR_REQUIREMENTS` — pointer to the updated spec docs and the diff range that describes what changed in the spec.
- `BASE_SHA` / `HEAD_SHA` — the commit range covering the revision.
- `DESCRIPTION` — 1–3 sentence human summary.

## Handling Feedback

The agent **MUST** handle the returned feedback through `receiving-code-review`.

- **Critical** issues **MUST** be fixed.
- **Important** issues **MUST** be fixed unless explicitly waived by the user.
- **Minor** issues **MAY** be deferred but **MUST** be listed in the final report.

## Re-review

After fixes, the agent **SHOULD** re-dispatch the review on the new `HEAD_SHA` (which requires re-running the verification gate first).

## Final Report

The final report **MUST** include a `Review:` line summarizing the outcome.
