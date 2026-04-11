# Iron Law — Scoped to Spec-Driven Code

Conformance keywords follow RFC 2119.

## Statement

> Within a spec-driven implementation, no line of production code **SHALL** be added or modified unless a failing test that exercises it already exists, has been run, and its failure has been recorded as `proof-type: tdd-red` evidence.

This is the spec-coexist translation of the superpowers TDD Iron Law. It is **not** imported, and it is **intentionally narrower**: the Iron Law applies to code whose behaviour is specified by `docs/main-requirements.md`, `docs/main-basic-design.md`, or a subsystem equivalent.

## Application boundary

The Iron Law **MUST** apply when ALL of the following hold:

1. A requirements document **AND** a basic design document exist for the target.
2. The change modifies executable production code (not config, docs, fixtures, or generated artifacts).
3. The change is reachable from at least one acceptance bullet extractable from the basic design.

The Iron Law **MAY** be waived when ANY of the conditions in `negative-triggers.md` hold.

## Waivers

A waiver **MUST**:

- be recorded via `../_shared/scripts/write_evidence.sh` with `proof-type: tdd-waiver`;
- cite which `negative-triggers.md` clause applies;
- name the human (or caller skill) that authorized the waiver;
- be scoped to a single change set. Open-ended waivers **MUST NOT** be issued.

A waiver **MUST NOT** be used to avoid a test that could reasonably be written. See `rationalization-table.md`.

## Commit-ordering constraint (backdating prevention)

The `tdd-red` evidence **MUST** be committed in a git commit that is an **ancestor** of the `tdd-green` commit. This is enforced by `_shared/scripts/verify_evidence.sh` via `git merge-base --is-ancestor`.

Concretely:
1. Write the failing test and commit it (produces `tdd-red` evidence with `commit_sha`).
2. Write production code to make the test pass, then commit (produces `tdd-green` evidence with `commit_sha`).
3. The CI gate verifies that `commit_sha(tdd-red)` is an ancestor of `commit_sha(tdd-green)`.

If the ordering is violated, the evidence is treated as **backdated** and the gate fails. There are no waivers for this constraint.

## Discovery of a violation

If `scripts/verify_test_first.sh` or a reviewer finds production code without a RED record, the default response **MUST** be:

1. Revert the offending change.
2. Re-do it test-first, producing a RED record.
3. Land the revert and the redo as separate commits.

An after-the-fact test **MUST NOT** be accepted as a substitute for RED evidence. A test that was never seen to fail is not a test.
