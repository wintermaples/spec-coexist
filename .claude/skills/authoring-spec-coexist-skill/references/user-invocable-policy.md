# `user-invocable` Policy

Every spec-coexist skill declares `user-invocable: true` or `user-invocable: false` in its frontmatter. The flag controls whether the user can run the skill directly (via the `Skill` tool or `/` shorthand) or whether the skill is only reachable through another skill's orchestration.

## Set `user-invocable: true` when

- The skill represents a **user-meaningful unit of work**. A sentence like "I want to do X" makes sense for X = the skill's purpose.
  - Examples: "create requirements", "implement from the spec", "debug this", "review my change".
- The skill can be started from a clean state without a hidden prerequisite that only another skill knows.
- Invoking the skill directly does not bypass a safety gate that exists for a reason.

## Set `user-invocable: false` when

- The skill is an **orchestration trigger** whose whole job is to route to other skills (e.g. `using-spec-coexist`).
- The skill is meaningful only as an internal step of another skill, and invoking it directly would produce incomplete or misleading output.
- Direct invocation would skip state that the calling skill is supposed to set up.

## Default

If in doubt, **default to `true`**. Blocking direct invocation is a strong restriction and should be justified. The suite prefers "user could call it but usually won't" over "user can't call it even when they need to".

## Current suite at a glance

| Skill | user-invocable | Why |
|---|---|---|
| `using-spec-coexist` | false | Pure router; nothing to do if invoked directly. |
| `creating-requirements` | true | User-meaningful unit of work. |
| `creating-basic-design` | true | Same. |
| `implementing-from-spec` | true | Same. |
| `revising-spec` | true | Same. |
| `revising-implementation` | true | Same. |
| `systematic-debugging` | true | Users directly say "this is broken". |
| `verification-before-completion` | true | Can be invoked standalone as a gate, and *must* be callable from other skills. |
| `requesting-code-review` | true | Same logic as verification. |
| `receiving-code-review` | true | Same. |
| `authoring-spec-coexist-skill` | true | User-meaningful ("make a new skill"). |

## Anti-patterns

- Marking a user-facing skill as `false` to "prevent misuse". That is what hard constraints and HALT conditions are for.
- Marking an orchestration-only skill as `true` "just in case". That pollutes the user's slash-command space with non-functional entries.
