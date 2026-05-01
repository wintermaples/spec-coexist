# Mandatory Code Review — revising

Skipping review is **NOT** permitted, even for small revisions — small changes are exactly where silent regressions hide.

## Invocation

After the verification gate passes, the agent **MUST** invoke `code-review-loop` with these inputs:

- `WHAT_WAS_IMPLEMENTED` — summary of the revision.
- `PLAN_OR_REQUIREMENTS` — pointer to the updated spec docs and the diff range that describes what changed in the spec.
- `BASE_SHA` / `HEAD_SHA` — commit range that covers the revision.
- `DESCRIPTION` — a one- to three-sentence human summary.

## Handling feedback

The agent **MUST** process the returned feedback through `code-review-loop`, applying these severity rules:

- **Critical** issues **MUST** be fixed.
- **Important** issues **MUST** be fixed unless explicitly waived by the user.
- **Minor** issues **MAY** be deferred, but **MUST** be listed in the final report.

## Re-review

After fixes are applied, the agent **SHOULD** re-dispatch the review on the new `HEAD_SHA`. Doing so requires re-running the verification gate first.

## Final report

The final report **MUST** include a `Review:` line that summarizes the outcome.
