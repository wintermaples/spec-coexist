# Verification Modes — verification-before-completion

The five gate steps are the same for every artifact — only the *proof* differs.

## Code Mode

Applies to: `implementing-from-spec`, `revising-implementation`, `systematic-debugging`.

The agent **MUST** run, at minimum:

1. The project's test suite (or a documented relevant subset).
2. Type checks, if the project uses them.
3. Linters / formatters, if the project uses them.
4. For `systematic-debugging`: the original reproduction case **MUST** no longer trigger the bug, and a regression test **MUST** exist and pass.

If any of these are absent, the agent **MUST** say so explicitly rather than silently skip them.

### Tier-aware TDD evidence

When the claim is driven by `implementing-from-spec` or `revising-implementation`, the gate **MUST** read the declared `test-strategy` tier from the target basic design and confirm the *tier-appropriate* evidence shape. Absent or wrong-shape evidence → HALT.

| Tier | Required artifacts for PASS |
|---|---|
| `strict` *(default)* | One `docs/evidence/red-*.log` per acceptance criterion bullet, or a documented `docs/evidence/tdd-waiver-*.md`. |
| `pipeline` | One `docs/evidence/red-*.log` per transform stage **and** the committed sample fixture(s) referenced by that stage under `docs/fixtures/{stage}/` (input + expected output). Missing fixture = HALT even if a RED log exists. |
| `ui` | One `docs/evidence/red-*.log` per user interaction (behavior / contract test) **and** a dated `docs/evidence/ui-manual-*.md` covering every pure-visual / layout criterion. A `ui` claim with no `ui-manual-*.md` = HALT. |

Tiers narrow the *unit* of observation; they never remove the loop. The per-instance `tdd-waiver-*.md` path remains available for residue no tier covers. See `../implementing-from-spec/references/tdd-discipline.md` §Test Strategy Tiers.

## Document Mode

Applies to: `creating-requirements`, `creating-basic-design`, `revising-spec`.

The agent **MUST** verify:

1. The target file exists at the expected path (use `../_shared/scripts/check_doc_exists.sh`).
2. The document conforms to the bundled template: every required section is present, order matches, frontmatter matches.
3. No unresolved placeholders remain — no `TBD`, `TODO`, `???`, `<fill in>`, or empty bullet lists.
4. For `revising-spec`: lockstep consistency between requirements and basic design when both were updated.
5. For `creating-basic-design` and `revising-spec`: every requirement in scope is traceable to at least one design element.
