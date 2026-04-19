---
name: revising
user-invocable: true
description: |
  Use whenever the user wants to REVISE spec documents (requirements or basic design) OR UPDATE
  implementation after a spec change. Trigger on phrases like "要件を変更したい", "設計を直したい",
  "revise the spec", "update the requirements", "仕様変更を実装に反映", "update the code to match
  the new spec", "実装を直したい", "the spec changed, fix the code". Handles both spec-mode and
  implementation-mode internally. Do NOT trigger for creating new specs from scratch (use
  creating-requirements or creating-basic-design instead).
  This skill is self-contained and MUST NOT delegate to any `superpowers:*` skill.
---

# revising

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill.

## Purpose

Unified revision skill that handles two modes:
- **Spec mode** — revise requirements or basic design documents in lockstep
- **Implementation mode** — update code after a spec change, with TDD

The mode is determined from the user's request. Both modes share brainstorming flow and verification gates.

## Mode Detection

- Mentions "requirements", "design", "spec", "要件", "設計" → **spec mode**
- Mentions "implementation", "code", "実装", "コード" → **implementation mode**
- If both → start with spec mode, then chain to implementation mode

## Spec Mode Procedure

1. Verify documents exist via `../_shared/scripts/check_doc_exists.sh`. HALT if missing.
2. Read documents. Resolve locale per `../_shared/templates/README.md`.
3. Brainstorm per `references/brainstorming-flow.md`.
4. Decide scope — if both req + design affected, update in lockstep.
5. Apply targeted edits. Bump `version`. Follow `../_shared/references/doc-lifecycle.md`.
6. Run `../_shared/scripts/check_doc_links.sh --root docs --strict`.
7. Pass `spec-coexist:verification-before-completion` (document mode).

## Implementation Mode Procedure

1. Verify spec documents exist. HALT if missing.
2. Read specs + inspect recent git diffs (`git log -p -- docs/`).
3. Brainstorm revision plan per `references/brainstorming-flow.md`.
4. Invoke `spec-coexist:test-driven-implementation` for each behavior change.
5. Apply targeted, minimal implementation changes.
6. Pass `spec-coexist:verification-before-completion` (code mode).
7. Invoke `spec-coexist:code-review-loop` and handle feedback (mandatory for all tiers — small revisions are where silent regressions hide).
8. Report diff summary, evidence paths, and `Review:` outcome line.

## Flow

```mermaid
flowchart TD
    Start([Skill invoked]) --> Mode{Spec or Impl?}
    Mode -- Spec --> SE[Verify docs exist]
    SE --> SB[Brainstorm]
    SB --> SW[Update docs in lockstep]
    SW --> SV[verification-before-completion]
    Mode -- Impl --> IE[Verify specs + read diffs]
    IE --> IB[Brainstorm revision plan]
    IB --> IT[TDD for each change]
    IT --> IV[verification-before-completion]
    IV --> IR[code-review-loop]
    SV --> Done([Done])
    IR --> Done
```

## References

- `references/brainstorming-flow.md` — one-question-per-message rules
- `references/lockstep-constraints.md` — document existence, lockstep rule, verification gate
- `references/hard-constraints.md` — implementation mode halt conditions, TDD Iron Law
- `references/mandatory-code-review.md` — review protocol for implementation mode
- `../_shared/references/visual-companion.md` — Visual Companion launch protocol

## Scripts

- `scripts/gen_questions_path.sh` — canonical path for pending-questions file
- `../_shared/scripts/check_doc_exists.sh` — document existence check
- `../_shared/scripts/check_doc_links.sh` — link + lifecycle checker
- `../_shared/scripts/record_test_failure.sh` — RED evidence capture
