# Verification Evidence Schema

Every successful run of the `verification-before-completion` gate **MUST** leave a record under `docs/evidence/`. The record is the sole audit point: downstream skills (e.g. a future `finishing-subsystem-work`) will check for its presence as a precondition, and reviewers can grep the directory to reconstruct the "done" history of the repository.

Records are written by `_shared/scripts/write_evidence.sh`. Do not hand-write them — the script guarantees the filename convention and hash, which matter for correlation.

## Filename

```
docs/evidence/verification-<UTC-timestamp>-<slug>.md
```

- `UTC-timestamp`: `YYYYMMDDTHHMMSSZ`, produced by `date -u +%Y%m%dT%H%M%SZ`. UTC and second-granularity together make collisions effectively impossible for human-driven workflows.
- `slug`: up to 40 chars, derived from the `subject` argument by lowercasing, replacing whitespace/`/`/`:` with `-`, and stripping non-`[a-z0-9-]` characters.

## Frontmatter (required)

```yaml
---
timestamp_utc: 20260408T110237Z
mode: code            # or: document
subject: subsystem:03_payment impl
result: pass          # or: fail
proof_hash: a1b2c3d4e5f6
review_ref: docs/reviews/03_payment-2026-04-08.md   # optional
---
```

- **timestamp_utc** — same as in the filename; duplicated in frontmatter so the file is self-contained after a rename.
- **mode** — matches the verification mode used (see `verification-modes.md`). `code` = executable proof; `document` = artifact inspection.
- **subject** — short identifier of what was being claimed done. A human reading the filename should recognize it.
- **result** — `pass` is the normal case. `fail` records exist too: when the gate fails, the claim is withdrawn, but the attempt is preserved so a reviewer can see that the agent did not silently retry.
- **proof_hash** — 12-char sha256 prefix of `subject\nproof\n`. Two records with the same hash refer to the same logical claim (useful for correlating retries).
- **review_ref** — optional pointer to the code/document review outcome that backs this claim. Required in practice for any change that went through `requesting-code-review` (which is most changes).

## Body (required sections)

1. **`# Verification Evidence — <subject>`** — top-level heading.
2. **Mode / Result** — bulleted restatement, so grepping works without a YAML parser.
3. **Proof command / observation** — the exact command line that was executed, in a fenced code block. For `document` mode, the observation sentence (e.g. `"reviewed docs/main-basic-design.md §4, confirmed all SHOULD items addressed"`).
4. **Review outcome reference** — only if provided.
5. **Trailing attribution line** — identifies the generating script and this schema.

## What counts as "fresh" proof

The Iron Law in `gate-steps.md` requires that the proof be executed *now*, against the current tree state, after the last change the claim depends on. In practice:

- `code` mode: the command was re-run in the same conversation after the last file edit that could affect the outcome. A proof from 20 messages ago does not count.
- `document` mode: the document was re-read in full (not just diffed) after the last edit. A partial re-read does not count.

If the proof pre-dates the last mutating action, re-run before writing evidence.

## Failure records

When VERIFY fails, the gate **MUST** still write an evidence record with `result: fail`. This matters for two reasons:

1. It prevents silent retry loops — a reviewer can see exactly how many times a claim was attempted before succeeding.
2. It makes the gate honest: "no record = no attempt" is a useful invariant.

After writing the `fail` record, the gate **MUST NOT** proceed to a completion claim. The caller either fixes the underlying issue and re-invokes the gate, or reports honest failure to the user.

## Retention

Evidence files accumulate. When `docs/evidence/` grows past a few hundred entries, move older records to `docs/evidence/archive/YYYY-MM/`. This is a manual housekeeping operation, not a gate responsibility.

## Proof types

Evidence records carry a `proof-type` tag in the subject line (and MAY also use a frontmatter `proof-type` field) so reviewers can grep by category. The tags below are recognized; new ones **MUST** be appended here, never repurposed.

- `proof-type: tdd-red` — RED phase failure capture written by `test-driven-implementation/scripts/record_red_phase.sh`. Subject: `tdd-red:<slug>`. Records the failing test command and tail of stderr/stdout. Existence of a `tdd-red` record for a slug is a precondition for the matching `tdd-green` record.
- `proof-type: tdd-green` — GREEN phase pass capture written by `test-driven-implementation/scripts/record_green_phase.sh`. Subject: `tdd-green:<slug>`. The slug **MUST** match a prior `tdd-red` record (or a documented waiver) so RED → GREEN can be correlated.
- `proof-type: self-review` — written by `spec-coexist:enforcing-code-discipline` after the implementing agent has walked `code-quality-checklist.md` over its own diff. The evidence body MUST contain per-file section outcomes (`pass` / `fail: reason` / `n/a: reason`) and the red-flag scan result (`clean` or `rejected: #<row>`). A `self-review` record with `result: pass` is a MANDATORY precondition for `spec-coexist:requesting-code-review` and for any code-mode `verification-before-completion` pass that follows.
