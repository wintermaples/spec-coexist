# When Review is MANDATORY

The following events **MUST** trigger a review via `code-review-loop`:

- After `implementing-from-spec` finishes executing its plan, **before** reporting completion to the user.
- After `revising` applies its implementation revision, **before** reporting completion.
- After `systematic-debugging` applies a fix and the repro test passes, **before** reporting completion.
- Before merging any branch into `master` / `main`.

"It is simple" / "it is small" / "tests pass" are **NOT** valid reasons to skip review.
