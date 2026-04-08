---
name: using-spec-coexist
user-invocable: false
description: Use at the start of EVERY conversation in this project. Establishes the spec-coexist skill suite and the "1% rule" for invoking its skills. Trigger this whenever the user mentions requirements, specs, basic design, implementing from a spec, revising a spec or implementation, debugging, or anything that could even remotely involve spec-driven development in this repo.
---

# using-spec-coexist

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Purpose

Trigger skill for the `spec-coexist` suite. Apply the **1% rule** (see `references/1pct-rule.md`) to every incoming user message, tempered by the negative trigger list.

## Hard Rules

- The 1% rule **MUST** be applied to every user message (see `references/1pct-rule.md`).
- If a message matches a category in `references/negative-triggers.md` **and** carries no spec-driven signal, a suite skill **MUST NOT** be invoked.
- Any reference to a suite skill — in prose, inventory, tests, commits — **MUST** use the `spec-coexist:` prefix (see `references/namespace-policy.md`). Directory names on disk are not renamed.

## Skill Inventory

| Skill | When to invoke |
|-------|----------------|
| `spec-coexist:exploring-problem-space` | Diverge on an unstructured wish; produce a handoff memo before requirements begin. |
| `spec-coexist:creating-requirements` | Create a new requirements document. |
| `spec-coexist:creating-basic-design` | Create a new basic design document. |
| `spec-coexist:implementing-from-spec` | Implement code from existing requirements + basic design. |
| `spec-coexist:revising-spec` | Revise existing requirements or basic design. |
| `spec-coexist:revising-implementation` | Update implementation after a spec change. |
| `spec-coexist:systematic-debugging` | Any bug, test failure, or unexpected behavior. |
| `spec-coexist:parallelizing-subsystem-work` | Run ≥2 independent subsystems concurrently in isolated worktrees, then consolidate. |
| `spec-coexist:finishing-subsystem-work` | Integrate verified + reviewed work (commit shaping, changelog, push, PR, merge). |
| `spec-coexist:authoring-spec-coexist-skill` | Create, modify, or refactor any skill inside this suite. |

## Flow

```mermaid
flowchart TD
    A[User message received] --> N{Matches a<br/>negative-triggers category<br/>with no spec signal?}
    N -- Yes --> D[Respond normally]
    N -- No --> B{Could any spec-coexist<br/>skill apply, even 1%?}
    B -- Yes --> C[Invoke the matching skill<br/>via the Skill tool<br/>using spec-coexist: prefix]
    B -- No --> D
    C --> E[Follow the invoked skill exactly]
```

## References

- `references/1pct-rule.md` — the 1% rule: when to invoke, why it is non-negotiable, examples.
- `references/negative-triggers.md` — capped exclusion list that prevents misfires on unrelated messages.
- `references/namespace-policy.md` — why and how suite skills are always referenced with the `spec-coexist:` prefix.
- `references/instruction-priority.md` — how user instructions, suite skills, and defaults are ranked.
- `references/independence.md` — why this suite must not delegate to `superpowers:*` at runtime.
