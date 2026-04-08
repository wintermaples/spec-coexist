# TDD Evidence Protocol

Conformance keywords follow RFC 2119.

TDD evidence plugs into the existing `verification-before-completion` evidence schema (`_shared/references/evidence-schema.md`). This skill introduces two new `proof-type` values — `tdd-red` and `tdd-green` — and a `tdd-waiver` value for `negative-triggers.md` exclusions.

## Writing a RED record

`scripts/record_red_phase.sh <slug> -- <test-cmd>` **MUST** be used. Do not hand-craft records.

The script:

1. Runs `<test-cmd>`, capturing stdout+stderr.
2. Asserts exit code ≠ 0 (the test actually failed). On exit 0 it HALTs — RED does not exist.
3. Delegates to `_shared/scripts/write_evidence.sh` with `mode: code`, `subject: tdd-red:<slug>`.
4. Prints the evidence file path on stdout.

## Writing a GREEN record

`scripts/record_green_phase.sh <slug> -- <test-cmd>` **MUST** be used. The slug **MUST** match the preceding RED's slug so reviewers can grep a pair.

The script:

1. Runs `<test-cmd>`, capturing stdout+stderr.
2. Asserts exit code = 0. Non-zero HALTs — GREEN not reached.
3. Delegates to `write_evidence.sh` with `subject: tdd-green:<slug>`.
4. Prints the evidence file path on stdout.

## Correlation

`proof_hash` is derived from `subject\nproof\n`, so RED and GREEN have different hashes. Correlation is by shared `<slug>` in the filename.

## Waivers

A waiver is written with `subject: tdd-waiver:<slug>` and a body citing the exact `negative-triggers.md` clause. Unsourced waivers **MUST** be rejected by reviewers.

## Verification integration

`verification-before-completion` (code mode) **MUST** accept a `tdd-red` + `tdd-green` pair (or a `tdd-waiver`) as minimum TDD proof for a spec-driven change. Absence of either **MUST** cause the gate to fail.
