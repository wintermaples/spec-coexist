---
name: requesting-code-review
user-invocable: true
description: Use whenever implementation work, a spec-driven change, or a bug fix has just been completed and needs verification before being considered done. Trigger on phrases like "コードレビューして", "review this change", "実装できたのでレビュー", "before I merge". This skill dispatches a fresh code-reviewer subagent with a precisely scoped prompt so the reviewer evaluates the diff — not the session history — and MUST be invoked by implementing-from-spec, revising-implementation, and systematic-debugging before they report completion.
---

# requesting-code-review

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill. The review is performed by a freshly spawned general-purpose subagent using the template at `code-reviewer.md` (sibling file).

## References

- `references/why-fresh-subagent.md` — rationale for dispatching a fresh subagent.
- `references/mandatory-triggers.md` — events that MUST trigger a review.
- `references/severity-policy.md` — severity thresholds and pushback rules.

## Scripts

- `scripts/collect-review-context.sh [--base <sha>]` — emits `BASE_SHA` and `HEAD_SHA`; fails if the working tree is dirty.

## Procedure

1. **Collect the git range and context.** Run `scripts/collect-review-context.sh` and capture `BASE_SHA` / `HEAD_SHA`. If changes are still unstaged, commit them first or pass a working-tree diff explicitly. Also prepare:
   - `WHAT_WAS_IMPLEMENTED`
   - `PLAN_OR_REQUIREMENTS`
   - `DESCRIPTION`
2. **Dispatch a subagent** (Task tool, `general-purpose`). Build the prompt by filling every `{PLACEHOLDER}` in `code-reviewer.md`. Send the filled template verbatim as the subagent's opening prompt.
3. **Wait for the reviewer's structured response** (Strengths / Critical / Important / Minor / Assessment).
4. **Act on the feedback** via `receiving-code-review`.
5. **Re-review after fixes.** After applying Critical/Important fixes, the agent **SHOULD** re-dispatch on the new `HEAD_SHA`.
6. **Record the outcome.** The calling skill **MUST** include a `Review: <verdict>` line in its final report.
