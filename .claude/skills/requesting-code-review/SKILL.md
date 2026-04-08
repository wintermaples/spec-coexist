---
name: requesting-code-review
user-invocable: true
description: Use whenever implementation work, a spec-driven change, or a bug fix has just been completed and needs verification before being considered done. Trigger on phrases like "コードレビューして", "review this change", "実装できたのでレビュー", "before I merge". This skill dispatches a fresh code-reviewer subagent with a precisely scoped prompt so the reviewer evaluates the diff — not the session history — and MUST be invoked by implementing-from-spec, revising-implementation, and systematic-debugging before they report completion.
---

# requesting-code-review

## Conformance Keywords

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals, as shown here.

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill. The review is performed by a freshly spawned general-purpose subagent using the embedded template at `code-reviewer.md`, so no external skill package is required.

## Why a Fresh Subagent

A dispatched subagent receives only the carefully scoped prompt below — not the entire session history. This matters because:

1. The reviewer evaluates the **work product**, not the author's thought process. This avoids confirmation bias ("the author clearly meant well, so it's fine").
2. The main agent's context is preserved for continued work instead of being consumed by review chatter.
3. A fresh perspective is more likely to catch assumptions that became invisible to the implementer.

## When Review is MANDATORY

The following events **MUST** trigger a review via this skill:

- After `implementing-from-spec` finishes executing its plan, **before** reporting completion to the user.
- After `revising-implementation` applies its revision, **before** reporting completion.
- After `systematic-debugging` applies a fix and the repro test passes, **before** reporting completion.
- Before merging any branch into `master` / `main`.

"It is simple" / "it is small" / "tests pass" are **NOT** valid reasons to skip review. The whole point of mandatory review is to catch issues that look invisible to the author.

## Procedure

1. **Determine the git range to review.**
   ```bash
   BASE_SHA=$(git rev-parse HEAD~1)   # or the commit before this work started
   HEAD_SHA=$(git rev-parse HEAD)
   ```
   If the work spans multiple commits, set `BASE_SHA` to the commit **before** the first one. If changes are still unstaged, the agent **MUST** either commit them first or explicitly pass the working-tree diff to the reviewer.

2. **Collect the context the reviewer needs:**
   - `WHAT_WAS_IMPLEMENTED` — a one-paragraph summary of what changed.
   - `PLAN_OR_REQUIREMENTS` — a pointer to the spec / plan / bug description the change is supposed to satisfy.
   - `BASE_SHA`, `HEAD_SHA`.
   - `DESCRIPTION` — 1–3 sentence human summary.

3. **Dispatch a subagent** (Task tool, `general-purpose` type) whose prompt is built by filling in the placeholders of `code-reviewer.md` (sibling file to this SKILL.md). The subagent prompt **MUST** include the filled template verbatim so the reviewer uses the same rubric every time.

4. **Wait for the reviewer's structured response** (Strengths / Critical / Important / Minor / Assessment).

5. **Act on the feedback** using the `receiving-code-review` skill. That skill governs *how* to evaluate the feedback and respond. This skill is only responsible for requesting it.

6. **Re-review if Critical or Important issues were fixed.** After applying fixes, the agent **SHOULD** re-dispatch the reviewer on the new `HEAD_SHA` to confirm the fixes actually resolve the issues and didn't introduce new ones.

7. **Record the outcome.** The calling skill **MUST** include a short "Review: <verdict>" line in its final report to the user, so the user knows review happened and what the verdict was.

## Severity Policy

- **Critical** — **MUST** be fixed before the calling skill reports completion.
- **Important** — **MUST** be fixed before the calling skill reports completion, unless the user is explicitly asked and explicitly waives it.
- **Minor** — **MAY** be deferred. If deferred, the agent **MUST** list them in the final report so they are not lost.

## Pushback

If the reviewer is technically wrong, the agent **SHOULD** push back using the `receiving-code-review` skill's rules (technical reasoning, reference to code/tests). Pushback is legitimate; performative agreement is not.

## Template

The subagent prompt template lives at `code-reviewer.md` in this skill directory. Fill in every `{PLACEHOLDER}` before dispatching.
