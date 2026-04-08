# systematic-debugging — Anti-patterns

## "Let me try changing X and see if it works."

**MUST NOT.** Form a hypothesis first. A blind change produces no information when it fails and false confidence when it accidentally works.

## "Tests pass now, must be fixed."

**MUST NOT** without understanding *why*. A test that passes because of an unrelated side effect will fail again when that side effect is cleaned up.

## "This looks suspicious, let me clean it up too."

Out of scope. Note it separately. Mixing cleanup into a bug fix makes the fix harder to review and impossible to revert cleanly.

## "It worked on my last run — I'll skip the verification gate."

**MUST NOT.** See `references/principles.md` §5.

## "The fix is tiny — I'll skip the review."

**MUST NOT.** Size is not a proxy for correctness.
