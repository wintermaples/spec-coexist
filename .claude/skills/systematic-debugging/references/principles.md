# systematic-debugging — Principles

## 1 — Hypothesis before action

The agent **MUST** proceed via a hypothesis → experiment → observation loop. It **MUST NOT** apply fixes based on guesses. A change applied without a hypothesis produces no information when it fails and false confidence when it happens to work.

## 2 — Root cause before fix

**MUST** identify the root cause before applying any fix. "It works now" is not the same as "I understand why it broke." Fixes applied to symptoms reappear in disguised form.

## 3 — Evidence before completion claim

The agent **MUST NOT** stop at "appears to be fixed." A reproducing test case **MUST** pass and a regression test **SHOULD** be added.

## 4 — Disproof is progress

If a hypothesis is disproved, that is progress. Form a new hypothesis informed by what was learned.

## 5 — Fresh verification gate

Once a fix is applied, the agent **MUST** pass `verification-before-completion` (code mode) — re-running the original repro, the regression test, and the full relevant test suite with fresh output — before declaring the bug fixed.

## 6 — Mandatory review after verification

After the verification gate reports PASS, the agent **MUST** route the change through `code-review-loop` before declaring the bug fixed.
