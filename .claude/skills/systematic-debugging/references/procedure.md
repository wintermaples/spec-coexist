# systematic-debugging — Procedure

Ten mandatory steps. Do them in order.

### 1 — Reproduce

Get the bug to occur on demand. If you cannot reproduce it, you cannot fix it. Investigate environmental differences first.

### 2 — Reduce

Strip the repro down to the smallest input/scenario that still triggers the bug.

### 3 — Hypothesize

State, in one sentence, what you think is causing the bug. Be specific.

### 4 — Experiment

Design the cheapest experiment that would confirm or disconfirm the hypothesis. Prints, targeted tests, `git bisect`, assertions.

### 5 — Observe

Run the experiment, record what actually happened, compare to predicted.

### 6 — Iterate

Disproved → new hypothesis. Confirmed but shallow → drill deeper. Only proceed to step 7 when the root cause (not a symptom) is confirmed.

### 7 — Fix

Apply the **smallest** change that addresses the root cause. No collateral refactors.

### 8 — Verify (MANDATORY)

Pass through `verification-before-completion` (code mode):

1. Re-run the original reproduction case. MUST no longer trigger the bug.
2. Run the regression test (add one if missing). MUST pass.
3. Run the full relevant test suite. Read the full output.

### 9 — Review (MANDATORY)

1. Run `scripts/get_review_range.sh` to obtain `BASE_SHA` and `HEAD_SHA`.
2. Invoke `requesting-code-review` with WHAT_WAS_IMPLEMENTED, PLAN_OR_REQUIREMENTS (bug report / failing test), BASE_SHA/HEAD_SHA, DESCRIPTION.
3. Handle feedback via `receiving-code-review`.
4. Critical MUST be fixed. Important MUST be fixed unless waived. Minor MAY be deferred but listed.
5. After fixes, re-run step 8, then re-dispatch the reviewer.

### 10 — Report

State: root cause, fix, regression test (path + assertion), and a `Review:` outcome line.
