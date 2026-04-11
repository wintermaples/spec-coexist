# Namespace Policy

Several skill names in this suite (`systematic-debugging`, `code-review-loop`, `verification-before-completion`, `writing-plans`-adjacent work, etc.) **collide** with skill names in `superpowers`. In repositories where both suites are installed, an unqualified reference can route to either implementation, breaking the suite's **independence** guarantee (see `independence.md`).

## Rule

All references to skills in this suite, whether in prose, SKILL.md bodies, trigger tests, commit messages, or user-facing output, **MUST** be written with the `spec-coexist:` prefix.

Examples:

- ✅ `spec-coexist:systematic-debugging`
- ✅ `spec-coexist:verification-before-completion`
- ❌ `systematic-debugging` (ambiguous when superpowers is present)
- ❌ `the debugging skill` (underspecified)

The skill **directory names** on disk are not renamed — history, inventory indexes, and external links would break. Only *references* carry the prefix.

## Scope

This rule applies to:

- `SKILL.md` bodies and their `references/` files inside `.claude/skills/`.
- The Skill Inventory table in `spec-coexist-router/SKILL.md`.
- `_shared/tests/trigger-cases.jsonl` — the `skill` field **SHOULD** remain the bare directory name (it is a filesystem pointer, not a routing request), but any prose `note` that mentions another skill **MUST** qualify it.
- Commit messages and PR descriptions that mention a skill by name.

It does **not** apply to:

- The `name:` field in a skill's own frontmatter (that field is the bare directory name by convention).
- Internal filesystem paths such as `references/...`.

## Why not rename?

Renaming every skill to carry the prefix on disk would:

1. Break every existing reference in commit history.
2. Double-prefix when the CLI already resolves by namespace.
3. Force the suite to diverge from the one-word-per-directory convention used by every other Claude skill suite.

The discipline is cheaper at the reference site.

## Enforcement

A lightweight lint in `_shared/tests/run_trigger_tests.sh` **SHOULD** warn when a test prompt or trigger fires an unqualified skill name in an environment where `superpowers` is also installed. The warning is non-blocking today; it becomes blocking once the cross-suite conflict surface stabilizes.

When authoring a new skill via the `_meta/authoring-skill` guide, step 7 (register in inventory) **MUST** use the prefixed form.
