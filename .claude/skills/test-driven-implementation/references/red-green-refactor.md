# RED-GREEN-REFACTOR in spec-coexist Vocabulary

Conformance keywords follow RFC 2119.

## RED

- One acceptance bullet from the basic design **MUST** drive one RED test.
- The test **MUST** fail for the right reason: assertion failure, not import error or syntax error.
- The failure **MUST** be captured by `scripts/record_red_phase.sh <slug> -- <cmd>` → `tdd-red` evidence record.
- If the test unexpectedly passes, HALT. Either the feature already exists (update the plan) or the test is wrong (fix it).

## GREEN

- Write the **minimal** production code that turns the RED test green. No speculative generalization, no extra methods, no adjacent refactors.
- The pass **MUST** be captured by `scripts/record_green_phase.sh <slug> -- <cmd>` with the same slug as RED. Pair correlation is by slug.
- All pre-existing tests **MUST** still pass at GREEN. If any regress, HALT and fix before moving on.

## REFACTOR

- Refactor **MUST NOT** change observable behaviour. If it does, it is a new feature and requires a fresh RED.
- The full test suite **MUST** be re-run after refactoring. The pre-refactor GREEN record remains valid only while behaviour is unchanged.
- Refactor is **optional**; skipping it is not a waiver.

## Loop boundary

One RED → GREEN → REFACTOR loop covers **one** acceptance bullet. Do not batch bullets in a single RED. Small loops keep evidence clean and rollback cheap.
