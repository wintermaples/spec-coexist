# SKILL.md Template (spec-coexist suite)

Copy this skeleton when creating a new skill. Replace every `{{placeholder}}`. Keep the body ≤ 80 lines (frontmatter excluded).

```markdown
---
name: {{skill-name}}
user-invocable: {{true|false}}
description: Use whenever {{main trigger condition in English}}. Trigger on phrases like "{{日本語フレーズ1}}", "{{日本語フレーズ2}}", "{{English phrase 1}}", "{{English phrase 2}}". {{Do NOT trigger for ... }}. This skill is self-contained and MUST NOT delegate to any `superpowers:*` skill.
---

# {{skill-name}}

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill. See `../_meta/authoring-references/independence-rationale.md`.

## Purpose

{{One paragraph: what problem this skill solves, and why it cannot be handled by an existing skill.}}

## When to Trigger

- {{concrete trigger case 1}}
- {{concrete trigger case 2}}

Do NOT trigger for: {{negative case(s)}}.

## Ordered Steps

1. **{{Step1}}** — {{what to do, in one line. Put detail in references/.}}
2. **{{Step2}}** — {{...}}
...
N. **Verify** — invoke `verification-before-completion` ({{code|document}} mode).
N+1. **Report** — state outcome + `Review:` line.

## Flow

```mermaid
flowchart TD
    Start([Invoked]) --> S1[{{Step1}}]
    S1 --> S2[{{Step2}}]
    S2 --> V[verification-before-completion]
    V --> End([Done])
```

## References

- `references/{{file1}}.md` — {{why read this}}
- `references/{{file2}}.md` — {{why read this}}

## Scripts (invoke, do not reimplement)

- `../_shared/scripts/{{script}}.sh` — {{one-line description}}
  (or "None." if the skill has no side effects)
```

## Filling rules

- **name** matches the directory name exactly.
- **user-invocable** — see `user-invocable-policy.md`.
- **description** — see `description-rules.md`. Must contain JA + EN triggers and the independence clause.
- **Ordered Steps** — imperative, numbered. Each step ≤ 1 line in the body; detail goes to `references/`.
- **Flow** — Mermaid diagram mirroring the steps. Optional for trivial skills, but recommended; it aids reviewer comprehension.
- **References** — every `references/*.md` file that the body mentions must exist before the skill is considered conformant.

## What does NOT belong in the body

- Multi-paragraph rationale (→ `references/rationale.md` or similar).
- Full templates or examples longer than ~10 lines (→ `references/*-template.md`).
- Script source code (→ `scripts/` or `_shared/scripts/`).
- Anti-pattern catalogs (→ `references/anti-patterns.md`).
