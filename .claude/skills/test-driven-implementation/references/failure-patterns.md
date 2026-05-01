# TDD Failure Patterns

Conformance keywords follow RFC 2119.

The following patterns **MUST** be recognized and rejected. Each entry has three parts: **Smell** (how to spot it), **Why wrong** (the underlying defect), and **Correction** (what to do instead).

## 1. Test-after masquerade

**Smell:** A test is added in the same commit as production code, with no RED record preceding it.
**Why wrong:** The test was never seen to fail. It could be tautological or green by accident.
**Correction:** Revert, write the test first, capture RED, re-add production code.

## 2. Assertion-free test

**Smell:** The test runs the code but contains no `assert`, only "did not throw".
**Why wrong:** Anything that does not crash passes. No discriminating power.
**Correction:** Add explicit expected-value assertions derived from the basic design.

## 3. Tautology test

**Smell:** The test asserts `f(x) == f(x)` or compares to a constant computed from the same code path.
**Why wrong:** Cannot fail even if the production code is wrong.
**Correction:** Compare to a value derived independently — from the spec, a hand-worked example, or a reference implementation.

## 4. Over-mocked test

**Smell:** Every collaborator is mocked; the test only verifies mock call arguments.
**Why wrong:** Tests the current shape, not behaviour. Refactor breaks the test without behaviour change.
**Correction:** Mock at architectural seams only (network, clock, filesystem). Real collaborators otherwise.

## 5. RED via import error

**Smell:** "RED" is achieved because the tested module fails to import.
**Why wrong:** Import errors are typos, not feature absence. The test never exercised behaviour.
**Correction:** Make the module importable, then re-run the test for a proper assertion failure.

## 6. Skipped RED record

**Smell:** The agent writes the test, sees it fail mentally, and skips `record_red_phase.sh`.
**Why wrong:** Evidence is the contract. "I saw it fail" is not auditable.
**Correction:** Run `record_red_phase.sh`. Always.

## 7. Batched loop

**Smell:** One RED covers five bullets; a single giant GREEN turns them all at once.
**Why wrong:** Rollback is expensive, correlation impossible, partial progress un-shippable.
**Correction:** One RED per bullet. Five loops, five evidence pairs.

## 8. Copy-pasted GREEN record

**Smell:** The GREEN evidence file is hand-edited from an older run.
**Why wrong:** It does not prove the current tree is green. The Iron Law requires fresh proof.
**Correction:** Always run `record_green_phase.sh` fresh against the current tree.
