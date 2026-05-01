# Authoring spec-coexist Skills (Meta Reference)

This is a **meta reference**, not a daily-use skill. It documents how to author or modify skills
in the spec-coexist suite. Detailed references live in `authoring-references/`.

## When to Use

- Creating a brand-new skill under `.claude/skills/<name>/`
- Modifying the description, trigger phrases, or steps of an existing skill
- Splitting a bloated SKILL.md into `references/`

## Quick Checklist

1. **Intent** — state the skill's single purpose in one sentence
2. **Classify** — `user-invocable: true|false` (see `authoring-references/user-invocable-policy.md`)
3. **Draft description** — JA + EN triggers, negative cues, independence clause
4. **Write thin SKILL.md** — body ≤ 80 lines (frontmatter excluded)
5. **Externalize** — scripts to `_shared/scripts/` or `<skill>/scripts/`
6. **Independence clause** — MUST NOT invoke `superpowers:*`
7. **Register in inventory** — update `spec-coexist-router/SKILL.md`
8. **Trigger tests** — ≥3 positive, ≥1 negative in `_shared/tests/trigger-cases.jsonl`
9. **Self-review** — walk `authoring-references/conformance-checklist.md`
10. **Verify** — invoke `verification-before-completion` (document mode)

## Hard Constraints

- SKILL.md body ≤ 80 lines
- Description must have JA + EN trigger phrases + independence clause
- No regulation text > 3 consecutive paragraphs in SKILL.md body
- No inlined scripts beyond a single invocation example

## References

All detailed references are in `authoring-references/`:
- `skill-template.md` — copy-ready skeleton
- `description-rules.md` — anatomy of a conformant description
- `user-invocable-policy.md` — true vs false
- `hard-constraints.md` — line/length/content constraints
- `conformance-checklist.md` — final self-review checklist
- `trigger-tests.md` — trigger-cases.jsonl format
- `independence-rationale.md` — why no superpowers delegation
- `skill-tdd-protocol.md` — RED-GREEN-REFACTOR for skills
- `pressure-scenarios.md` — adversarial scenarios
