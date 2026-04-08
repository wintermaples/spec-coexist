# Self-Review Protocol

The exact sequence the implementing agent **MUST** follow when running
`spec-coexist:enforcing-code-discipline`. This is a self-review — performed by the same agent that
wrote the code, with the full diff in view. It is **not** a fresh subagent dispatch; that role
belongs to `spec-coexist:requesting-code-review`.

Conformance keywords follow RFC 2119.

## Step 1 — Collect the diff

Run `scripts/run_self_review.sh` from the repository root. It emits:

1. `BASE_SHA` and `HEAD_SHA`.
2. A `git diff --stat` summary of changed files.
3. A findings skeleton (one `## <file>` block per changed file) the agent fills in.

HALT if the diff is empty. There is nothing to self-review and invoking this skill was a mistake.

## Step 2 — Walk the checklist per file

For **each** changed file, open `code-quality-checklist.md` and read it end-to-end. For each
section (SOLID, naming, complexity, boundaries, error handling, dead code, secrets, logging), the
agent **MUST** explicitly state one of:

- `pass` — every question in the section is answered affirmatively.
- `fail: <concise reason>` — at least one question is answered negatively; capture the reason.
- `n/a: <concise reason>` — the section does not apply (e.g. "no logging added"); capture why.

Silent skips are forbidden. A missing answer is treated as `fail` by the evidence gate.

## Step 3 — Classify findings

Each `fail` is assigned a severity from
`../../requesting-code-review/references/severity-policy.md`:

- **Critical** — must fix in-session. No exceptions.
- **Important** — must fix in-session. No exceptions.
- **Minor** — may be deferred with a written one-line rationale in the evidence body.

Findings from this self-review **MUST NOT** be forwarded to the reviewer subagent.

## Step 4 — Fix and re-walk

After fixing, re-run `scripts/run_self_review.sh` to capture the new `HEAD_SHA`. Re-walk **only the
affected sections** of the affected files; unrelated sections need not be re-walked.

## Step 5 — Red-flag scan

Read `red-flags.md`. If any listed rationalization matches the agent's own reasoning about why a
finding "does not really count" or "can wait", the agent **MUST** reject that reasoning and return
to Step 3.

## Step 6 — Write evidence

Invoke `../../_shared/scripts/write_evidence.sh` with:

- `subject` — short description of the change under self-review.
- `proof-type: self-review` — see
  `../../verification-before-completion/references/evidence-schema.md`.
- Body — per-file section outcomes, severity of any deferred Minor findings, and the red-flag scan
  result (`clean` or `rejected: <rationalization id>`).

## Step 7 — Hand off

Only after the evidence record is written (and `result: pass`) **MAY** the caller invoke
`spec-coexist:requesting-code-review`. The reviewer subagent is told nothing about this
self-review; it evaluates the diff on its own merits.
