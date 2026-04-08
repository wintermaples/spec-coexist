---
name: verification-before-completion
user-invocable: true
description: Use whenever another skill — or the agent itself — is about to claim that a task is "done", "complete", "fixed", "passing", "implemented", or otherwise finished. Trigger on phrases like "終わりました", "完了しました", "実装できました", "fixed it", "all done", "tests pass", or any statement that asserts a positive end state. This skill is a hard gate; NO completion claim may be made without fresh verification evidence. It MUST be invoked by creating-requirements, creating-basic-design, revising-spec, implementing-from-spec, revising-implementation, and systematic-debugging before they report back to the user. This skill is self-contained and MUST NOT delegate to any `superpowers:*` skill.
---

# verification-before-completion

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill.

## The Iron Law

> **No completion claim may be made without fresh verification evidence.**

"Fresh" means: executed *now*, against the current state of the tree, after the last change that the claim depends on. See `references/gate-steps.md` for rationale.

## Trigger

Any of the following is a "completion claim" and therefore **MUST** be preceded by this gate:

- "Done", "完了", "実装できました", "fixed", "ready", "all green", "tests pass".
- Reporting the end of a skill.
- Committing, opening a PR, or asking for merge.
- Handing control back to the user with an implicit "over to you".

## Gate (ordered steps)

| Step | Name | What to do |
|------|------|------------|
| 1 | **IDENTIFY** | State the claim and identify its proof command or observation. |
| 2 | **RUN** | Execute fresh, in full, against the current tree. |
| 3 | **READ** | Read the full output; check exit code, failure counts, warnings. |
| 4 | **VERIFY** | Compare observed output to the claim. Fix or report honestly if they disagree. |
| 5 | **CLAIM WITH EVIDENCE** | Make the claim *with* what / how / result attached. |

Full step definitions, examples, rationale, and flow diagram: `references/gate-steps.md`.

What counts as proof differs by artifact type (code vs document): `references/verification-modes.md`.

Anti-patterns and invalid rationalizations: `references/anti-patterns.md`.

## Pre-flight script

Before step 1, optionally run the deterministic pre-flight checker:

```bash
.claude/skills/verification-before-completion/scripts/run_gate_checklist.sh [code|document]
```

It verifies that the necessary tooling is present. It does **NOT** run tests — you still **MUST** execute steps 1–5.

## Procedure

1. Before any completion-style report, pause and state the claim you are about to make.
2. Optionally run `run_gate_checklist.sh` to surface environment gaps.
3. Execute Gate steps 1–5 in order (see `references/gate-steps.md`).
4. Use the correct verification mode (see `references/verification-modes.md`).
5. If VERIFY fails, fix the underlying issue OR report actual status honestly — **MUST NOT** claim completion.
6. When and only when VERIFY passes, make the claim with evidence (what / how / result).
