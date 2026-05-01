# Lockstep Constraint Rules — revising

## Document existence

Before any revision work begins, these existence checks **MUST** pass:

- `docs/main-requirements.md` **MUST** exist. If missing, HALT immediately.
- `docs/main-basic-design.md` **MUST** exist. If missing, HALT immediately.
- For subsystem revisions, both `{name}-requirements.md` and `{name}-design.md` **MUST** exist; if either is missing, HALT.

Use `check_doc_exists.sh <path>` from `../_shared/scripts/` — do not reimplement the check inline.

## Lockstep update rule

When a revision affects both the requirements document and the basic design document, the skill **MUST** update **both** in the same invocation; the two documents **MUST NOT** diverge. Decide which documents are affected **before** writing any edits, and when both are affected, hold all edits until you are ready to apply them together.

## Test Strategy Tier Changes

When a revision changes the basic design's `test-strategy` tier (§7.0 for whole-system, §12.0 for a subsystem), the revision **MUST**:

- update the rationale in the same edit — a tier change with a stale rationale is a Critical review defect;
- be surfaced to the user at report time with an explicit note that downstream `spec-coexist:implementing-from-spec` / `spec-coexist:revising` runs **MUST** re-extract acceptance criteria under the new tier;
- not be used to silently weaken tests on an already-implemented subsystem — if code exists, the user **MUST** explicitly acknowledge that the weaker evidence shape is acceptable for the existing code.

Tier changes are a spec-level decision. They **MUST NOT** be introduced from inside `implementing-from-spec` or `revising`.

## Targeted Edits Only

Apply targeted edits — change only what the revision requires. Do **NOT** rewrite sections for style, restructure unrelated content, or silently alter wording.

## Verification Gate (MANDATORY)

After applying edits, and before reporting completion, the agent **MUST** pass `verification-before-completion` (document mode):

1. Re-read every touched file from disk.
2. Confirm template conformance for each file.
3. Confirm lockstep consistency between requirements and basic design when both were updated.
4. Confirm no `TBD`/`TODO`/`???` or empty bullets were introduced.
