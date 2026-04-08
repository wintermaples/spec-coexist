# Lockstep Constraint Rules — revising-spec

## Document Existence

Before any revision work begins:

- `docs/main-requirements.md` **MUST** exist. If missing, HALT immediately.
- `docs/main-basic-design.md` **MUST** exist. If missing, HALT immediately.
- For subsystem revisions, both `{name}-requirements.md` and `{name}-design.md` **MUST** exist. If either is missing, HALT.

Use `check_doc_exists.sh <path>` from `../_shared/scripts/` — do not reimplement inline.

## Lockstep Update Rule

When a revision affects both the requirements document and the basic design document, the skill **MUST** update **both** in the same invocation. The two documents **MUST NOT** diverge. Decide which documents are affected **before** writing any edits. If both are affected, hold all edits until you are ready to apply them together.

## Targeted Edits Only

Apply targeted edits — change only what the revision requires. Do **NOT** rewrite sections for style, restructure unrelated content, or silently alter wording.

## Verification Gate (MANDATORY)

After applying edits, and before reporting completion, the agent **MUST** pass `verification-before-completion` (document mode):

1. Re-read every touched file from disk.
2. Confirm template conformance for each file.
3. Confirm lockstep consistency between requirements and basic design when both were updated.
4. Confirm no `TBD`/`TODO`/`???` or empty bullets were introduced.
